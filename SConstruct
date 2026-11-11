#!/usr/bin/env python

import os
import sys
from methods import print_error

libname = "macmousefix"
projectdir = "project"

localEnv = Environment(tools=["default"], PLATFORM="")

customs = ["custom.py"]
customs = [os.path.abspath(path) for path in customs]

opts = Variables(customs, ARGUMENTS)
opts.Update(localEnv)

Help(opts.GenerateHelpText(localEnv))

env = localEnv.Clone()

if not (os.path.isdir("godot-cpp") and os.listdir("godot-cpp")):
    print_error("""godot-cpp is not available within this folder, as Git submodules haven't been initialized.

Run the following command to download godot-cpp:

git submodule update --init --recursive""")
    sys.exit(1)

env = SConscript("godot-cpp/SConstruct", {"env": env, "customs": customs})

if env["platform"] != "macos":
    print_error("Deze extension is alleen bedoeld voor macOS. Gebruik: scons platform=macos")
    sys.exit(1)

env.Append(CPPPATH=["src/"])
env.Append(LINKFLAGS=["-framework", "AppKit"])

objc_env = env.Clone()
objc_env.Append(CCFLAGS=["-fobjc-arc"])
objc_objects = [objc_env.SharedObject(f) for f in Glob("src/*.mm")]

sources = Glob("src/*.cpp") + objc_objects

suffix = env["suffix"].replace(".dev", "").replace(".universal", "")

lib_filename = "{}{}{}{}".format(env.subst("$SHLIBPREFIX"), libname, suffix, env.subst("$SHLIBSUFFIX"))

library = env.SharedLibrary(
    "bin/{}/{}".format(env["platform"], lib_filename),
    source=sources,
)

copy = env.Install("{}/bin/{}/".format(projectdir, env["platform"]), library)

default_args = [library, copy]
Default(*default_args)
