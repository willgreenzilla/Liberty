# WebSphere Liberty
Some potentially useful WebSphere Liberty scripts. There does not seem to be a ton of stuff for Liberty available currently.

## LIB_pluginbuilder.sh
This script makes managing multiple plugin-cfg files from Liberty applications on multiple Liberty server hosts easy.

To use, create a directory named plugins at `/opt/IBM/wlp/plugins` (or anywhere, as defined in the PLUGINPATH variable). Add the various Liberty applications to `LIBERTYSERVERS`, the various host server hostnames to `APPSERVERS`, set `NOTME` as every host server hostname that is NOT the one the script is ran from, and set `PLUGINHOME` to the location of the webserver destination `plugin-cfg.xml`.

When ran with the build command, the script will use pluginUtility to generate a fresh plugin-cfg.xml for every indicated Liberty application on every indicated Liberty server host and will pool them into the plugins directory. Once all plugin files are pooled they will be merged with the pluginUtility merge command into a single `plugin-cfg.xml` file.

To push the merged `plugin-cfg.xml` out to all webservers indicated in `WEBSERVERS` use the push command, this will push the merged plugin to every webserver and also bounce IHS.

To build and push: `./LIB_pluginbuilder.sh build;./LIB_pluginbuilder.sh push`
