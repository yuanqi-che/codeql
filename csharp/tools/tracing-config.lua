function RegisterExtractorPack(id)
    local csharpExtractor = GetPlatformToolsDirectory() ..
                                'Semmle.Extraction.CSharp.Driver'
    if OperatingSystem == 'windows' then
        csharpExtractor = GetPlatformToolsDirectory() ..
                              'Semmle.Extraction.CSharp.Driver.exe'
    end

    function DotnetMatcherBuild(compilerName, compilerPath, argv)
        if compilerName ~= 'dotnet' then return nil end

        -- The dotnet CLI has the following usage instructions:
        -- dotnet [sdk-options] [command] [command-options] [arguments]
        -- we are interested in dotnet build, which has the following usage instructions:
        -- dotnet [options] build [<PROJECT | SOLUTION>...]
        -- however, `dotnet -h build`, although documented, does not work
        -- For now, parse the command line as follows:
        -- Everything that starts with `-` will be ignored.
        -- The first non-option argument is treated as the command.
        -- if that's `build`, we append `/p:UseSharedCompilation=false` to the command line,
        -- otherwise we do nothing.
        local match = false
        for i, arg in ipairs(argv) do
            -- the first argument in argv is `dotnet`, skip that
            -- TODO windows check if this assumption holds
            if i > 1 then
                -- TODO check if on Windows, `/` is also applicable for options
                if not string.sub(arg, 1, 1) == '-' then
                    if arg == 'build' then match = true end
                    break
                end
            end
        end
        if match then
            table.insert(argv, '/p:UseSharedCompilation=false')
            return {
                trace = true,
                replace = true,
                invocations = {{path = compilerPath, argv = argv}}
            }
        else
            return nil
        end
    end

    function DotnetMatcherExec(compilerName, compilerPath, argv)
        if compilerName ~= 'dotnet' then return nil end
        -- TODO on windows this doesn't split argv correctly
        local match = false
        local newArgv = {'--compiler'}
        for i, arg in ipairs(argv) do
            -- TODO check if this is the correct regex, or if it should be more specific (and escape the dots!)
            if arg:match('csc.exe') or arg:match('mcs.exe') or
                arg:match('csc.dll') then
                match = true
                -- newArgv contains all elements of argv from i+1 to the end
                table.insert(newArgv, arg)
                table.insert(newArgv, '--cil')
                for j = i + 1, #argv do
                    table.insert(newArgv, argv[j])
                end
                break
            end
        end
        if not match then return nil end
        return {
            trace = true,
            replace = false,
            invocations = {
                {
                    path = AbsolutifyExtractorPath(id, csharpExtractor),
                    argv = newArgv
                }
            }
        }
    end

    -- TODO windows matchers patterns
    local matchers = {
        CreatePatternMatcher({'^fakes.*%.exe$', '^moles.*%.exe$'},
                             MatchCompilerName, nil, {trace = false}),
        CreatePatternMatcher({'^mcs%.exe$', '^csc.*%.exe$'}, MatchCompilerName,
                             csharpExtractor,
                             {prepend = {'--compiler', '${compiler}', '--cil'}}),
        -- Note that the order here is intentional - if we find `dotnet build`,
        -- we do not execute the action for `dotnet` that comes next in the list
        DotnetMatcherBuild,
        -- TODO we could replace this unconditional extractor invocation with some smarter Lua code.
        -- Then, after the legacy driver has been removed, we could remove the --dotnetexec mode of
        -- the extractor driver.
        CreatePatternMatcher({'^dotnet%.exe$', '^dotnet$', '^mono.*$'},
                             MatchCompilerName, csharpExtractor,
                             {prepend = {'--dotnetexec', '--cil'}})
    }

    -- On Posix, we disable shared compilations for msbuild and xbuild
    if IsPosix() then
        table.insert(matchers,
                     CreatePatternMatcher({'^msbuild$', '^xbuild$'},
                                          MatchCompilerName, '${compiler}', {
            append = {
                '/p:UseSharedCompilation=false',
                options = {replace = true}
            }
        }))
    end
    return matchers
end

-- Return a list of minimum supported versions of the configuration file format
-- return one entry per supported major version.
function GetCompatibleVersions() return {'1.0.0'} end
