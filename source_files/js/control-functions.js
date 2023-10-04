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
// 
showGrid();
switchType(1);
