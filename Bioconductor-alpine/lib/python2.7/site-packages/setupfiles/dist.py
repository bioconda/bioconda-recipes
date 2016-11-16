#!/usr/bin/env python
import os
# import distutils
from distutils import dist

cwd = os.getcwd()

def lines(string):
    if not string:
        return []
    _lines = string.splitlines()
    _lines = list(filter(lambda l: l.lstrip().rstrip(), _lines))
    _lines = list(filter(lambda l: l, _lines))
    return _lines

def read(path):
    if os.path.exists(path) and os.path.isfile(path):
        return open(path).read()

def readlines(path):
    if os.path.exists(path) and os.path.isfile(path):
        read = open(path).read()
        return lines(read)
    return []

# class DistributionMetadata(distutils.dist.DistributionMetadata):
class DistributionMetadata(dist.DistributionMetadata):
    # todo: entry_points
    def get_name(self):
        # return self.name or "UNKNOWN"
        if self.name:
            return self.name
        key = "NAME"
        if key in os.environ and os.environ[key]:
            return os.environ[key]
        return os.path.basename(cwd).split(".")[0].lower()

    def get_version(self):
        # return self.version or "0.0.0"
        if self.version:
            return self.version
        for filename in ["version.txt","version"]:
            path = os.path.join(cwd,filename)
            if read(path):
                return read(path)
        key = "VERSION"
        if os.environ.get(key,None):
            return os.environ[key]
        return "0.0.0"

    def get_license(self):
        # return self.license or "UNKNOWN"
        if self.license:
            return self.license
        key = "LICENCE"
        if os.environ.get(key,None):
            return [os.environ[key]]
        return "UNKNOWN"

    def get_description(self):
        # return self._encode_field(self.description) or "UNKNOWN"
        if self.description:
            return self.description
        for filename in ["description","description.txt"]:
            path = os.path.join(cwd,filename)
            if read(path):
                return read(path)
        key = "DESCRIPTION"
        if key in os.environ and os.environ[key]:
            return os.environ[key]
        return "UNKNOWN"

    def get_long_description(self):
        # return self._encode_field(self.long_description) or "UNKNOWN"
        if self.long_description:
            return self.long_description
        for filename in ["README.rst","README"]:
            path = os.path.join(cwd,filename)
            if read(path):
                return read(path)
        key = "LONG_DESCRIPTION"
        if os.environ.get(key,None):
            return os.environ[key]
        return "UNKNOWN"

    def get_keywords(self):
        # return self.keywords or []
        if self.keywords:
            return self.keywords
        path = os.path.join(cwd,"keywords.txt")
        if read(path):
            return [read(path)]
        key = "KEYWORDS"
        if os.environ.get(key,None):
            return [os.environ[key]]
        return []

    def get_platforms(self):
        # return self.platforms or ["UNKNOWN"]
        if self.platforms:
            return self.platforms
        path = os.path.join(cwd,"platforms.txt")
        if read(path):
            return [read(path)]
        key = "PLATFORMS"
        if os.environ.get(key,None):
            return [os.environ[key]]
        return ["UNKNOWN"]

    def get_classifiers(self):
        # return self.classifiers or []
        if self.classifiers:
            return sorted(self.classifiers)
        classifiers = []
        path = os.path.join(cwd,"classifiers.txt")
        if os.path.exists(path):
            classifiers = readlines(path)
        key = "CLASSIFIERS"
        if key in os.environ and os.environ[key]:
            classifiers+=os.environ[key].splitlines()
        classifiers = filter(None,classifiers) # remove empty
        classifiers = list(set(classifiers)) # unique
        return list(sorted(classifiers))

    def get_download_url(self):
        # return self.download_url or "UNKNOWN"
        if self.download_url:
            return self.download_url
        key = "DOWNLOAD_URL"
        if os.environ.get(key,None):
            return os.environ[key]
        return "UNKNOWN"

    def get_url(self):
        # return self.url or "UNKNOWN"
        if self.url:
            return self.url
        key = "URL"
        if os.environ.get(key,None):
            return os.environ[key]
        return "UNKNOWN"
