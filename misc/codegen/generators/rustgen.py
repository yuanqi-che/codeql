"""
Rust trap class generation
"""

import functools
import typing

import inflection

from misc.codegen.lib import rust, schema
from misc.codegen.loaders import schemaloader


def _get_type(t: str) -> str:
    match t:
        case None | "boolean":  # None means a predicate
            return "bool"
        case "string":
            return "String"
        case "int":
            return "i32"
        case _ if t[0].isupper():
            return "TrapLabel"
        case _:
            return t


def _get_field(cls: schema.Class, p: schema.Property) -> rust.Field:
    table_name = None
    if not p.is_single:
        table_name = f"{cls.name}_{p.name}"
        if p.is_predicate:
            table_name = inflection.underscore(table_name)
        else:
            table_name = inflection.tableize(table_name)
    args = dict(
        field_name=p.name + ("_" if p.name in rust.keywords else ""),
        base_type=_get_type(p.type),
        is_optional=p.is_optional,
        is_repeated=p.is_repeated,
        is_predicate=p.is_predicate,
        is_unordered=p.is_unordered,
        table_name=table_name,
    )
    args.update(rust.get_field_override(p.name))
    return rust.Field(**args)


def _get_properties(
    cls: schema.Class, lookup: dict[str, schema.Class]
) -> typing.Iterable[schema.Property]:
    for b in cls.bases:
        yield from _get_properties(lookup[b], lookup)
    yield from cls.properties


class Processor:
    def __init__(self, data: schema.Schema):
        self._classmap = data.classes

    def _get_class(self, name: str) -> rust.Class:
        cls = self._classmap[name]
        return rust.Class(
            name=name,
            fields=[
                _get_field(cls, p)
                for p in _get_properties(cls, self._classmap)
                if "rust_skip" not in p.pragmas and not p.synth
            ],
            table_name=inflection.tableize(cls.name),
        )

    def get_classes(self):
        ret = {"": []}
        for k, cls in self._classmap.items():
            if not cls.synth and not cls.derived:
                ret.setdefault(cls.group, []).append(self._get_class(cls.name))
        return ret


def generate(opts, renderer):
    assert opts.rust_output
    processor = Processor(schemaloader.load_file(opts.schema))
    out = opts.rust_output
    groups = set()
    for group, classes in processor.get_classes().items():
        group = group or "top"
        groups.add(group)
        renderer.render(
            rust.ClassList(
                classes,
                opts.schema,
            ),
            out / f"{group}.rs",
        )
    renderer.render(
        rust.ModuleList(
            groups,
            opts.schema,
        ),
        out / f"mod.rs",
    )
