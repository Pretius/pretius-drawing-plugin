# User manual

## Map/Plan settings 

To adjust settings, click on the map settings button

You can adjust plan size and enable/disable grid background

<div  style="float: left"><p  align="center">
<img  src="readme_files/map_settings.gif"  width="800"  />
</p></div>

## Adding components to plan

User can drag and drop components from right pane to plan

<div  style="float: left"><p  align="center">
<img  src="readme_files/adding_components.gif"  width="800"  />
</p></div>

## Changing size and angle

User can change component size and rotate it

To adjust the size click right bottom corner of the component and drag

To rotate a component, select it first and click Rotate button

<div  style="float: left"><p  align="center">
<img  src="readme_files/size_angle.gif"  width="800"  />
</p></div>

## Removing elements from plan

To remove elements from the plan, click on the elements to select them and then click Delete selected button

<div  style="float: left"><p  align="center">
<img  src="readme_files/removing.gif"  width="800"  />
</p></div>

## Adding components

To add component, you add html code and css into TYPE_COMPONENT table

It will automatically appear in the plugin right component pane

<div>
<img  src="readme_files/html.png"  width="33%"  />
<img  src="readme_files/css.png"  width="33%"  />
<img  src="readme_files/result.png"  width="33%"  />
</div>

## Calibration

To adjust the component's drop position, you can use the 'Left Margin' and 'Top Margin' attributes in the region settings.

Drag and drop the component into the planner and pay attention to whether it appears in the correct spot where you dropped it. If not, adjust the margin values and repeat the process.

Margins may need to be adjusted each time you change the region type, padding, or margins.

<div  style="float: left"><p  align="center">
<img  src="readme_files/calibration.png"  width="800"  />
</p></div>

## Add planner background
To add planner background simply upload the image into Application static files and use the name of the file in plugin background settings. You can also set the opacity of the background. 
After you upload the image file into the static files, use only the actual path to te file without APP_FILES. For example if you have static file with path "#APP_FILES#test-bg.png" use only test-bg.png as path.

<div  style="float: left"><p  align="center">
<img  src="readme_files/background-options2.png"  width="800"  />
</p></div>
<div  style="float: left"><p  align="center">
<img  src="readme_files/adding-background.gif"  width="800"  />
</p></div>
