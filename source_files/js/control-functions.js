/**
 * Switches the active component type and displays the corresponding components row.
 *
 * @function
 * @param {string} id - The ID of the component type to switch to.
 * @returns {void}
 */
function switchType(id) {
    // Prepare the selector for the target components row
    var idPrepared = `div#${id}.components-row`;
    var componentsRow = $(idPrepared);

    // Toggle visibility of all components rows, hiding others
    $('.components-row').hide();
    componentsRow.show();

    // Toggle the active state of type buttons
    var buttonClicked = `li#${id}`;
    $('li.t-Tabs-item').removeClass('a-Tabs-selected');
    $('li.t-Tabs-item').removeClass('is-active');
    $(buttonClicked).addClass('a-Tabs-selected');
    $(buttonClicked).addClass('is-active');
}

/**
 * Toggles the grid background on the 'droppable' element.
 *
 * @function
 * @returns {void}
 */
function showGrid() {
    // Check if the 'droppable' element has the 'grid-background' class
    if ($('#droppable').hasClass('grid-background')) {
        // If it has the class, remove it to hide the grid background
        $('#droppable').removeClass('grid-background');
    } else {
        // If it doesn't have the class, add it to show the grid background
        $('#droppable').addClass('grid-background');
    }
}

/**
 * Toggles the visibility of the map settings dropdown menu.
 *
 * @function
 * @returns {void}
 */
function toggleMapSettings() {
    // Toggle the "show" class on the "mapSettingsDropdown" element to control visibility
    document.getElementById("mapSettingsDropdown").classList.toggle("show");
}

var zoomScale = 1;
/**
 * Sets the zoom level of an element.
 *
 * @param {number} zoom - The zoom level to set.
 * @param {HTMLElement} el - The element to apply the zoom to. If not provided, the container element will be used.
 * @returns {void}
 */
function setZoom(zoom, el) {
    transformOrigin = [0, 0];
    var p = ["webkit", "moz", "ms", "o"],
        s = "scale(" + zoom + ")",
        oString = (transformOrigin[0] * 100) + "% " + (transformOrigin[1] * 100) + "%";
    for (var i = 0; i < p.length; i++) {
        el.style[p[i] + "Transform"] = s;
        el.style[p[i] + "TransformOrigin"] = oString;
    }
    el.style["transform"] = s;
    el.style["transformOrigin"] = oString;
}
/**
 * Updates the zoom scale and applies the zoom to the specified element.
 *
 * @param {number} a - The value to increment the zoom scale by.
 * @returns {void}
 */
function showVal(a) {
    var minDifference = 0;
    try{
        if (a == 'max'){
            var zoomContainerSize = [];
            var zoomContainer = document.querySelector('.zoom-additional-container');
            if (zoomContainer) {
                zoomContainerSize = [zoomContainer.offsetWidth, zoomContainer.offsetHeight];
            }
            var bodySize = [];
            var bodyContainer = document.querySelector('.dropable-zone-body');
            if (bodyContainer) {
                bodySize = [bodyContainer.offsetWidth, bodyContainer.offsetHeight];
            }
            //find minumum difference between zoomContainerSize and bodySize
            minDifference = Math.min(Math.abs(zoomContainerSize[0] / bodySize[0]), Math.abs(zoomContainerSize[1] / bodySize[1]));
        }
    }catch(err){
        console.log(err);
    }
    if(minDifference !== 0){
        zoomScale = minDifference;
    }else{
        zoomScale = zoomScale + Number(a);
    }
    setZoom(zoomScale, document.getElementsByClassName('dropable-zone-body')[0])
    //setZoom(zoomScale, document.getElementsByClassName('component')[0])
}
//Adding listener for deselectAll when clicked on the background
document.querySelectorAll('.dropable-zone-body').forEach(div => {
    div.addEventListener('click', function(event) {
        // Check if the clicked element is the div itself and not a child element
        if (event.target === this) {
            deselectAll();
        }
    });
});
showGrid();
switchType(1);
showVal(0);