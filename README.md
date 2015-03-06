# less-autocompile package

Auto compile LESS file on save.

---

Add the parameters on the first line of the LESS file.

```
out (string):  path of CSS file to create
compress (bool): compress CSS file
main (string): path to your main LESS file to be compiled
```

```
// out: ../styles.css
```

```
// out: ../styles.css, compress: true
```

```
// main: init.less
```

Ps: if u have more than one main file u can do this

```
// main: one.less|two.less|another.less
```

This is only working for main option

![](http://uppix.net/2pENDo.gif)
