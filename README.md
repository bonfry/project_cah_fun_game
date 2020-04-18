# Cards against humanity fun game
  
A dart full-stack application for playing cards against humanity (ITA) on web
  
## Getting Started  
  
This project is ready to play only on a desktop or tablet. For building the application we must install [last Flutter SDK](https://flutter.dev/docs/get-started/install) (from **beta or master branch**) and last [Dart release]([https://dart.dev/get-dart](https://dart.dev/get-dart)) and then we can start to build the application:

Before starting, you should create a directory (for example *cah_game*) where you put the flutter web application and the game server.

1. From project folder, open the terminal and write this command for **compiling flutter front end** 
 ```
 flutter build web
```
After that, copy the web build folder; which is on build directory of the project, in *cah_game* folder and rename it into **app**.

2.  **Build the game server app** with the command (change **\<path>** with the path for *cah_game* folder)
```
dart2native lib_webserver/main.dart -o <path>/cah_server.exe
```
3. Copy the directory *card_datasource* in *cah_game* 
4. Try the game executing `cah_server.exe` and connection at `localhost:4040/index.html`

## Credits

[Flutter](https://flutter.dev/) for the environment
[ProjectCah42]([https://www.cah42project.it/](https://www.cah42project.it/)) for the cards
[LittleRobotSoundFactory](https://freesound.org/s/270402/) for win song