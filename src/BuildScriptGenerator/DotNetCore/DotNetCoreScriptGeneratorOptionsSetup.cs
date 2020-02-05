﻿// --------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// --------------------------------------------------------------------------------------------

using Microsoft.Extensions.Options;

namespace Microsoft.Oryx.BuildScriptGenerator.DotNetCore
{
    internal class DotNetCoreScriptGeneratorOptionsSetup : IConfigureOptions<DotNetCoreScriptGeneratorOptions>
    {
        internal const string DefaultVersion = DotNetCoreRunTimeVersions.NetCoreApp21;

        private readonly IEnvironment _environment;

        public DotNetCoreScriptGeneratorOptionsSetup(IEnvironment environment)
        {
            _environment = environment;
        }

        public void Configure(DotNetCoreScriptGeneratorOptions options)
        {
            var defaultVersion = _environment.GetEnvironmentVariable(
                DotNetCoreEnvironmentSettingsKeys.DotNetCoreDefaultVersion);
            if (string.IsNullOrEmpty(defaultVersion))
            {
                defaultVersion = DefaultVersion;
            }

            options.DefaultVersion = defaultVersion;
            options.Project = _environment.GetEnvironmentVariable(DotNetCoreEnvironmentSettingsKeys.Project);
            options.MSBuildConfiguration = _environment.GetEnvironmentVariable(
                DotNetCoreEnvironmentSettingsKeys.MSBuildConfiguration);
        }
    }
}