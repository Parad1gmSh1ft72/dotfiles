# Web3D X3D/VRML2 format Add-on

## Features
see [Web3D X3D/VRML2 Documentation](https://projects.blender.org/extensions/io_scene_x3d/wiki)

### Import file formats
- .x3d
- .wrl

### Export file formats
- .x3d

## Guides

This add-on was part of [Blender 4.1 bundled add-ons](https://docs.blender.org/manual/en/4.1/addons/). This is now available as an extension on the [Extensions platform](https://extensions.blender.org/add-ons/web3d-x3d-vrml2-format).

To build a new version of the extension:
* `<path_to_blender.exe> --command extension build --source-dir=./source --output-dir=./output`

For more information about building extensions refer to the [documentation](https://docs.blender.org/manual/en/4.2/advanced/extensions/index.html).

## Contribute

This add-on is offered as it is and maintained by @Bujus_Krachus and the community, no support expected.

Contributions in form of [bug reports/feature requests](https://projects.blender.org/extensions/io_scene_x3d/issues), bug fixes, improvements, new features, etc. are always welcome as I don't have the time to do or know it all.

Code contributions:
- fork the repository, do your changes and create a Pull-Request to https://projects.blender.org/extensions/io_scene_x3d/src/branch/main. 
- It is best practice to keep the fork up-to-date with the main repo, follow the guidelines in ["Step-by-Step Workflow for merging two repos"](https://projects.blender.org/extensions/io_scene_x3d/issues/42) to do so.
- Describe as detailed as possible what this PR does and why it's good to have. Ideally include sample files for testing and demonstrating. Also make sure, that a merge of the PR does not break other features. 
- Code contributions by contributors with write permissions can also be done directly on the main branch of the main repo or for larger changes on a seperate branch inside the main repo.
- Pull Requests shall be created as early as possible as a WIP PR. Communication regarding the implemenation will happen there.

Checklist for PRs to get accpeted:
- The code follows the general python guidelines as much as possible: [Pep-8](https://peps.python.org/pep-0008/)
- The code shall be well documented, use docstrings where possible, add comments if needed and add as much details as possible to the PR message.
- Dead/commented out code shall be avoided or documented on when it shall be uncommented.
- Simplify the code. This improves readability and can imporve performance as well.
- The code has to be well tested, it should throw no python errors and work under different circumstances. Other code parts shall not break.
- Known limitations and future tasks should get mentioned.
- The newest blender version should work with the suggested changes. If a eralier version (4.2+) breaks, document it.
- And last but not least: keep the users in mind. As engineers we tend to overcomplicate, keep it simple, keep it straight-forward.

Fellow active maintainers are also always very welcome. If you're interested, reach out.

Releases will happen regularly after some code changes are done. We try to follow semantic versioning as much as possible.

Original authors: Campbell Barton, Bart, Bastien Montagne, Seva Alekseyev

## Specifications
For deeper understanding of both file formats supported by this extension, refer to:
- [VRML (.wrl)](https://graphcomp.com/info/specs/sgi/vrml/)
- [X3D (.x3d)](https://www.web3d.org/specifications/) and [X3D V3.3(.x3d)](https://www.web3d.org/documents/specifications/19775-1/V3.3/index.html)

Comparison software:
- [FreeWRL](https://freewrl.sourceforge.io/)
- [x3dom](https://www.x3dom.org/)
- [x_ite](https://create3000.github.io/x_ite/)

## License
[GPL-3.0](LICENSE.txt)
