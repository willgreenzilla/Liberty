# WebSphere Liberty
Some potentially useful WebSphere Liberty scripts. There does not seem to be a ton of stuff for Liberty available currently.

## LIB_pluginbuilder.sh
This script makes managing multiple plugin-cfg files from Liberty applications on multiple Liberty server hosts easy.

To use, create a directory named plugins at `/opt/IBM/wlp/plugins` (or anywhere, as defined in the PLUGINPATH variable). Add the various Liberty applications to `LIBERTYSERVERS`, the various host server hostnames to `APPSERVERS`, set `NOTME` as every host server hostname that is NOT the one the script is ran from, and set `PLUGINHOME` to the location of the webserver destination `plugin-cfg.xml`.

When ran with the build command, the script will use pluginUtility to generate a fresh plugin-cfg.xml for every indicated Liberty application on every indicated Liberty server host and will pool them into the plugins directory. Once all plugin files are pooled they will be merged with the pluginUtility merge command into a single `plugin-cfg.xml` file.

To push the merged `plugin-cfg.xml` out to all webservers indicated in `WEBSERVERS` use the push command, this will push the merged plugin to every webserver and also bounce IHS.

To build and push: `./LIB_pluginbuilder.sh build;./LIB_pluginbuilder.sh push`

## LIB_datasource_check.sh
This script makes testing all of the Liberty datasources quick and easy. I ended up creating a datsource include and include it to every Liberty application so it gets merged into the server.xml on application startup. You will need to add `jdbc-4.2` as a feature to the `server.xml` for the datasource(s) you plan to test.

Edit the `LIB_datasource_check.sh` `DATASOURCE_IDS` variable as a space separated list of every datasource id you have as datasources and `DATASOURCE_PATH` is the path and port of the application you will be using to test the datasources with. So, if you have an application called myapp1 at port 10499 set this `DATASOURCE_PATH` to `https://localhost:10499/ibm/api/validation/datasource/` (or to the hostname if application resides on another host) and make sure every datasource you intend to test is either in the myapp1 `server.xml` or in an include that is imported into the myapp1 `server.xml`. Set the `USERNAME` to the username used by the AdminCenter set with the `quickStartSecurity` tag in the `server.xml`.

To run: `./LIB_datasource_check.sh quick`|`full`

You will be prompted for a password, enter the password set with `quickStartSecurity` and the results will be displayed to screen of every datasource indicated in the script. Use quick for a short datasource status output and full for in-depth report including error information. `"successful": true` is a successful test, `"successful": false` is a failed test.
