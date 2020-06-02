﻿// --------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// --------------------------------------------------------------------------------------------

using System;
using System.IO;
using System.Xml.Linq;
using System.Xml.XPath;
using Microsoft.Extensions.Logging;

namespace Microsoft.Oryx.Detector.DotNetCore
{
    internal class DotNetCorePlatformDetector : IPlatformDetector
    {
        private readonly DefaultProjectFileProvider _projectFileProvider;
        private readonly ILogger<DotNetCorePlatformDetector> _logger;

        public DotNetCorePlatformDetector(
            DefaultProjectFileProvider projectFileProvider,
            ILogger<DotNetCorePlatformDetector> logger)
        {
            _projectFileProvider = projectFileProvider;
            _logger = logger;
        }

        public PlatformDetectorResult Detect(RepositoryContext context)
        {
            var projectFile = _projectFileProvider.GetRelativePathToProjectFile(context);
            if (string.IsNullOrEmpty(projectFile))
            {
                return null;
            }

            var sourceRepo = context.SourceRepo;
            var projectFileDoc = XDocument.Load(new StringReader(sourceRepo.ReadFile(projectFile)));
            var targetFrameworkElement = projectFileDoc.XPathSelectElement(
                DotNetCoreConstants.TargetFrameworkElementXPathExpression);
            var targetFramework = targetFrameworkElement?.Value;
            if (string.IsNullOrEmpty(targetFramework))
            {
                _logger.LogDebug(
                    $"Could not find 'TargetFramework' element in the project file.");
                return null;
            }

            var version = GetVersion(targetFramework);

            return new PlatformDetectorResult
            {
                Platform = DotNetCoreConstants.PlatformName,
                PlatformVersion = version,
            };
        }

        internal string DetermineRuntimeVersion(string targetFramework)
        {
            // Ex: "netcoreapp2.2" => "2.2"
            targetFramework = targetFramework.ToLower().Replace(
                "netcoreapp",
                string.Empty);

            // Ex: "2.2" => 2.2
            if (decimal.TryParse(targetFramework, out var val))
            {
                return val.ToString();
            }

            return null;
        }

        private string GetVersion(string targetFramework)
        {

            var version = DetermineRuntimeVersion(targetFramework);
            if (version != null)
            {
                return version;
            }
            _logger.LogDebug(
                   $"Could not determine runtime version from target framework. Getting default version.");
            return GetDefaultVersionFromProvider();
        }

        private string GetDefaultVersionFromProvider()
        {
            return PlatformVersionList.DotNetCoreDefaultVersion;
        }

    }
}