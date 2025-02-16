# Ipelets
Ipelets for IPE in lua

# BoxDraw
It shows a simple minimum of code snippets to create a fully functional custom tool for IPE.

## Important
* ```self.finish()`` needs to be called before ```self.model:creation```
* all methods are necessary except the ```self:compute()```
* be careful when using global variables! Some important already used global variable names are: name, path, dllname, _G, ipe, ipeui, math, string, table, assert, shortcuts, prefs, config, mouse, ipairs, pairs, print, tonumber, tostring!
* ```self.model:creation()``` takes a string and a ipe.Object as parameters. An ipe.object, for example, is an ipe.Path or a ipe.Groupe. ipe.Objects need shapes. Shapes are just lua lists and must be created manually because there is no ipe.Class. Also ipe.Segments do not work to create a shape!
