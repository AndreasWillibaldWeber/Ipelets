# Ipelets
Ipelets for IPE in lua

## StepArrowDiagram
It draws a single arrow to create a step arrow diagram using two points and some UI entries. 

## BoxDraw
It shows a simple minimum of code snippets to create a fully functional custom tool for IPE. It makes a rectangle by using two points. A line shows the diagonal of the future rectangle during drawing.

### Important
* To install the Ipelets, copy the lua file into the ```~/.ipe/ipelets``` folder. If you have installed the flatpak version of Ipe, copy the lua files into ```~/.var/app/org.otfried.Ipe/.ipe/ipelets```.
* To enable the quick reload tool create a ```prefs.lua``` file inside the ```ipelets``` folder. Then add the line ```prefs.developer = true``` to the file. It will appear in the ```Help/Developer``` menue.
* To fix the text editor default size of Ipe add ```prefs.editor_size = { 1000, 600 }``` to ```prefs.lua```.
* ```self.finish()`` needs to be called before ```self.model:creation```
* All methods are necessary except the ```self:compute()```
* Be careful when using global variables! Some important already used global variable names are: ```name```, ```path```, ```dllname```, ```_G```, ```ipe```, ```ipeui```, ```math```, ```string```, ```table```, ```assert```, ```shortcuts```, ```prefs```, ```config```, ```mouse```, ```ipairs```, ```pairs```, ```print```, ```tonumber```, ```tostring```!
* ```self.model:creation()``` takes a string and a ```ipe.Object``` as parameters. An ```ipe.object```, for example, is an ```ipe.Path``` or a ```ipe.Groupe```. ```ipe.Objects``` need shapes. Shapes are just lua lists and must be created manually because there is no ```ipe.Class```. Also ```ipe.Segments``` do not work to create a shape!

```lua
local shape = { type="curve", closed=true;
                    { type="segment"; V(self.p1.x, self.p1.y), V(self.p1.x, self.p2.y) },
                    { type="segment"; V(self.p1.x, self.p2.y), V(self.p2.x, self.p2.y) },
                    { type="segment"; V(self.p2.x, self.p2.y), V(self.p2.x, self.p1.y) },
                    { type="segment"; V(self.p2.x, self.p1.y), V(self.p1.x, self.p1.y) } }
```

### Useful Ipelets Code Examples
* https://github.com/lluisalemanypuig/ipe.autolabel
* https://github.com/Marian-Braendle/ipe-lassotool/blob/main/lassotool.lua
* https://github.com/otfried/ipe/blob/master/src/ipe/lua/main.lua
* https://github.com/otfried/ipelets

### Ipelib Documentation
* https://ipe.otfried.org/ipelib/index.html
