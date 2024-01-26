/**
 * Recreates the HTML elements from JSON data.
 *
 * @param {boolean} editable - Indicates whether the elements should be editable.
 * @param {string} region_id - Identify region.
 */
function recreateFromJson(editable, region_id) {
    console.log('recreateFromJson');
    region_id = region_id.id;
    //Fetching the data from divs
    var dataFromDivs = $(".json-data-" + region_id);
    console.log($(".json-data-" + region_id).length);
    var jsonFromDivs = "{";
    for (let index = 0; index < dataFromDivs.length; index++) {
        const element = dataFromDivs[index];
        jsonFromDivs = jsonFromDivs + $(element).data("json");
    }
    jsonFromDivs = jsonFromDivs + '}';
    jsonData = jsonFromDivs;
    // Parse the JSON string to get the data object
    var data = JSON.parse(jsonData);

    // Recreate the droppable zone with the saved size and position
    if (!editable) {
        //$('#wrapper')[0].innerHTML = "";
    }
    //var droppableDiv = editable ? $('#droppable') : $('<div id="droppable"></div>');
    var droppableDiv = $('#droppable.' + region_id);
    try {
        var width = (Object.keys(data).length > 0) ? data.droppable.width : document.getElementById("winput").value;
        var height = (Object.keys(data).length > 0) ? data.droppable.height : document.getElementById("hinput").value;
        if (editable) {
            droppableDiv.css({
                width: width,
                height: height
            });
        } else {
            droppableDiv.css({
                width: width,
                height: height,
                position: 'relative',
                backgroundColor: '#eee'
            });
        }
    } catch (err) {
        console.log('No inputs');
    }

    // Iterate over the divs in the JSON data and recreate them
    for (var key in data) {
        if (key !== 'droppable') {
            var divData = data[key];
            var div = $('<div class="remove" ' + (divData.available === 'Y' ? 'onClick="' + divData.onClick + '"' : '') + '></div>');
            if (editable) {
                div = $('<div class="remove" ' + 'onClick="select();"' + '></div>');
            }

            div.css({
                width: divData.width,
                height: divData.height,
                top: divData.top,
                left: divData.left,
                rotate: divData.rotate,
                position: 'absolute'//,
            });
            div.attr('id', key);
            div.addClass(divData.class); // Add the saved class to the recreated div
            // Create an input element, set the text from the JSON, and add availability class
            addInputAndAvailabilityClass(div, divData);
            addDivicons(div);
            droppableDiv.append(div);
            //Inner HTML for complicated components
            if (divData.class.includes("parking-space") || divData.class.includes("parking-space-vertical") || divData.class.includes("label")) {

            } else {
                try{
                    div[0].insertAdjacentHTML('beforeend', (divData.innerHtml).replaceAll('@', '"'));
                }catch(err){
                    console.log('No inner html');
                }
            }
        }
    }
    if (editable) {
        //Reactivate draggable and resizable
        $(".remove")
            .resizable({grid: [1, 1]})
            .draggable({grid: [1, 1]});

        addMobileFunctionality()
    } else {
        // Append the recreated droppable zone to the document body or any desired parent element
        $('#wrapper').append(droppableDiv);
    }
    //Fill size items with droppable values
    try {
        var selectElement = document.querySelector("#winput");
        var selectElement2 = document.querySelector("#hinput");
        selectElement.value = width;
        selectElement2.value = height;
    } catch (err) {
        console.log('No inputs');
    }
    $('.remove').bind('dragstop', function () { select(this) });
}
/**
 * Converts the data of resizable and draggable div elements into JSON format.
 *
 * @returns {string} The JSON string representation of the data.
 */
function saveToJson() {
    // Create an object to store the data
    var jsonData = {};

    // Get the size and position of the droppable div
    var droppableDiv = $("#droppable");
    var droppableData = {
        width: $(droppableDiv).css("width"),
        height: $(droppableDiv).css("height"),
        top: '0px',//droppableDiv.offset().top,
        left: '0px',//droppableDiv.offset().left,
        class: droppableDiv.attr('class'),
        spotId: droppableDiv.id
    };
    jsonData["droppable"] = droppableData;

    // Iterate over each resizable and draggable div
    $(".remove").each(function () {
        var id = this.id;
        var divData = {
            width: Math.round(parseFloat($(this).css("width"))) + 'px',
            height: Math.round(parseFloat($(this).css("height"))) + 'px',
            top: Math.round(parseFloat($(this).css("top"))) + 'px',
            left: Math.round(parseFloat($(this).css("left"))) + 'px',
            class: $(this).attr('class'),
            text: $(this).find('textarea').val(),
            rotate: $(this).css("rotate"),
            spotId: id,
            innerHtml: (this.innerHTML).replaceAll('"', '@').replace(/(\r\n|\n|\r)/gm, "")
        };
        jsonData[id] = divData;
    });

    // Convert the JSON object to a string
    var jsonString = JSON.stringify(jsonData);
    //console.log(jsonString);
    return jsonString;
}
/**
 * Changes the size of the droppable element based on the input values.
 */
function changeSize() {
    var w = document.getElementById("winput").value;
    var h = document.getElementById("hinput").value;

    var data = [
        { Width: w, Height: h }
    ];

    $('#droppable').css('width', w);
    $('#droppable').css('height', h);
}
/**
 * Generates a random ID string.
 *
 * @returns {string} The generated ID string.
 */
function makeid() {
    return 'new-id-' + Math.random().toString(36).substr(2, 9);
}

function prepareEditor() {
    var x = null;
    var t = '';
    //Make element draggable
    $(".drag").draggable({
        helper: 'clone',
        cursor: 'move',
        tolerance: 'fit',
        revert: true,
        grid: [1, 1]
    });

    $("#droppable").droppable({
        accept: '.drag',
        activeClass: "drop-area",
        drop: function (e, ui) {
            if ($(ui.draggable)[0].id == "drag") {
                x = ui.helper.clone();
                ui.helper.remove();
                x.draggable({
                    helper: 'original',
                    cursor: 'move',
                    //containment: '#droppable',
                    tolerance: 'fit',
                    drop: function (event, ui) {
                        $(ui.draggable).remove();
                    },
                    drag: function (event, ui) {
                        t = ui.position;
                    },
                    grid: [1, 1] // Adjust the grid size here (in pixels)
                });

                x.resizable({
                    grid: [1, 1]
                });
                var newId = makeid();

                x.attr('id', newId);
                x.addClass('remove');
                x.removeClass('drag');
                //Add input into DIV
                if ((x.hasClass("parking-space") || (x.hasClass("parking-space-vertical"))) && !x.find('.id-input').length) {
                    var input = $('<textarea type="text" placeholder="Enter text" class="id-input"/>');
                    x.append(input);
                }

                x.appendTo('#droppable');
                $('.delete').on('click', function () {
                    $(this).parent().parent('span').remove();
                });
                $('.delete').parent().parent('span').dblclick(function () {
                    $(this).remove();
                });
                var leftOffset = Number(x[0].offsetLeft);
                var topOffset = Number(x[0].offsetTop);

                x.css('position', 'absolute');
                //Calibration of drop margins
                var parentLeftMargin = ($('.drawing-plugin-body').parent().css("marginLeft")).replace('px', '');
                var element = $('.drawing-plugin-body').parent();
                var rect = $(element)[0].getBoundingClientRect();
                var parentTopMargin = rect.top;
                var leftMarginVal = $('.dropdown').data('leftMargin');
                var topMarginVal = $('.dropdown').data('topMargin');
                x.css("left", leftOffset - parentLeftMargin + leftMarginVal); //11 is left margin of component + border 1px
                x.css("top", topOffset - topMarginVal); //9 is margin of dropzone + border 1 px
                x.bind('dragstop', function () { select(this) });
            }
        }
    });
    $("#remove-drag").droppable({
        drop: function (event, ui) {
            $(ui.draggable).remove();
        },
        hoverClass: "remove-drag-hover",
        accept: '.remove'
    });
    const selectElement = document.querySelector("#winput");
    const selectElement2 = document.querySelector("#hinput");
    try {
        selectElement.addEventListener("change", (event) => {
            changeSize();
        });
        selectElement2.addEventListener("change", (event) => {
            changeSize();
        });
    } catch (err) {

    }

    //changeSize();
}

/**
 * Adds icons to the given div based on its classes.
 *
 * @param {jQuery} div - The jQuery object representing the div element.
 * @returns {jQuery} The modified jQuery object with added icons.
 */
function addDivicons(div) {
    var classToIcon = {
        'arrow-left': 'fa fa-arrow-left',
        'arrow-right': 'fa fa-arrow-right',
        'arrow-up': 'fa fa-arrow-up',
        'arrow-down': 'fa fa-arrow-down',
        'arrow-in-east': 'fa fa-box-arrow-in-east',
        'parking-space-paraplegic': 'fa fa-wheelchair'
        // Add any additional mappings here
    };

    div.each(function () {
        for (var className in classToIcon) {
            if ($(this).hasClass(className)) {
                var icon = $('<i class="' + classToIcon[className] + '"></i>');
                $(this).append(icon);
                break;
            }
        }
    });

    return div;
}
/**
 * Adds an input element and sets the text from the JSON to the given element.
 * Also adds an availability class based on the divData.available value.
 *
 * @param {jQuery} element - The jQuery element to which the input element and class should be added.
 * @param {Object} divData - The div data object containing the text and availability values.
 */
function addInputAndAvailabilityClass(element, divData) {
    if (element.hasClass("parking-space") || element.hasClass("parking-space-vertical") || element.hasClass("label")) {
        var input = $('<textarea type="text" placeholder="" class="id-input"/>');
        input.val(divData.text);
        element.append(input);

        // Dictionary for availability classes
        var availabilityClasses = {
            'Y': 'available',
            'N': 'not-available',
            'R': 'reserved',
            // Add any additional mappings here
        };

        // Add class based on availability
        var availabilityClass = availabilityClasses[divData.available] || '';
        if (!element.hasClass("label")) {
            element.addClass(availabilityClass);
        }
    }
}

/**
 * Rotates an element by a specified angle in degrees.
 *
 * @function
 * @param {string} pi_id - The ID of the element to be rotated.
 * @param {number} [pi_value=10] - The angle in degrees by which to rotate the element (default is 10 degrees).
 * @returns {void}
 */
function rotate(pi_id, pi_value) {
    var rotateByDeg = pi_value || 10;
    var thisElement = $(pi_id).parent();
    var currentDeg = thisElement.css("rotate");
    if (currentDeg == 'none') {
        thisElement.css("rotate", rotateByDeg + "deg");
    } else {
        currentDeg = currentDeg.match(/\d+/)[0];
        currentDeg.toString();
        var newDeg = Number(currentDeg) + Number(rotateByDeg);
        thisElement.css("rotate", newDeg + "deg");
    }
}
/**
 * Sets the image for a specific HTML element based on user input.
 * The image path is retrieved from an input field with the id "image-path".
 * The image is set on a div with the id "droppable".
 * The opacity of the image is determined by the value of an input field with the id "image-opacity".
 * The base URL for the image is retrieved from a data attribute ("data-app-files-path") on the div with the id "droppable".
 * If a checkbox with the id "background-switch" is checked, the image is set as the background image of the div.
 * If the checkbox is not checked, any existing background image on the div is removed.
 */
function setImage() {
    var imagePath = document.getElementById("image-path").value;
    var image = document.getElementById("droppable");
    var opacity = 1 - document.getElementById("image-opacity").value;
    //get the base url from data-app-files-path from div with id droppable
    var baseurl = document.getElementById("droppable").getAttribute("data-app-files-path");
    //if checkbox with id background-switch is checked, set the image as background image of div with id droppable
    if (document.getElementById("background-switch").checked) {
        image.style.backgroundImage = "linear-gradient( rgba(255,255,255," + opacity + "), rgba(255,255,255," + opacity + ")), url('" + baseurl + imagePath + "')";
        image.style.backgroundSize = "100% 100%";
    } else {
        image.style.backgroundImage = "";
        image.style.backgroundSize = "";
    }
}

/**
 * Selects or deselects an element based on its current state.
 *
 * @function
 * @param {HTMLElement} [pi_element] - The element to be selected. If not provided, the event target will be used.
 * @returns {void}
 */
function select(pi_element) {
    if (pi_element) {
        var selectedElement = pi_element;
    } else {
        var selectedElement = this.event.target;
    }
    if (!$(selectedElement).closest('.components-row').length > 0) {
        if (!$(selectedElement).hasClass('ui-resizable-handle')) {
            if (!$(selectedElement).hasClass('component') && !$(selectedElement).hasClass('id-input') && !$(selectedElement).hasClass('ignore-selected')) {
                selectedElement = $(selectedElement).closest('.component');
            }
            if ($(selectedElement).hasClass('selected')) {
                $(selectedElement).removeClass('selected');
            } else if ($(selectedElement).hasClass('component')) {
                $(selectedElement).addClass('selected');
            } else if (!$(selectedElement).hasClass('component')) {
                $(selectedElement).find('.component').addClass('selected');
            }
        }
    }
}

/**
 * Deselects all elements with the 'selected' class.
 * @function
 * @returns {void}
 */
function deselectAll() {
    var allSelected = Array.from($('.selected'));
    allSelected.forEach(element => {
        $(element).removeClass('selected');
    });
}

/**
 * Aligns divs with the class "selected" either horizontally or vertically based on the specified axis.
 * @param {string} axis - The axis to align the divs. Use "horizontal" for horizontal alignment and "vertical" for vertical alignment.
 */
function alignSelectedDivs(axis) {
    const selectedDivs = document.querySelectorAll('.selected');

    // Check if there are any selected divs, if not, there's nothing to align.
    if (selectedDivs.length === 0) {
        return;
    }

    if (axis === 'horizontal') {

        let totalHorizontalPosition = 0;

        // Calculate the total horizontal position sum of all selected divs.
        for (const div of selectedDivs) {
            const boundingRect = div.getBoundingClientRect();
            totalHorizontalPosition += boundingRect.left;
        }

        const averageHorizontalPosition = totalHorizontalPosition / selectedDivs.length;

        // Adjust the "left" CSS property of each selected div to align them horizontally.
        for (const div of selectedDivs) {
            const boundingRect = div.getBoundingClientRect();
            const currentLeft = boundingRect.left;
            const offset = averageHorizontalPosition - currentLeft;
            div.style.left = `${currentLeft + offset}px`;
        }
    } else if (axis === 'vertical') {
        let totalVerticalPosition = 0;

        // Calculate the total vertical position sum of all selected divs.
        for (const div of selectedDivs) {
            const boundingRect = div.getBoundingClientRect();
            totalVerticalPosition += boundingRect.top;
        }

        const averageVerticalPosition = totalVerticalPosition / selectedDivs.length;

        // Adjust the "top" CSS property of each selected div to align them vertically.
        for (const div of selectedDivs) {
            const boundingRect = div.getBoundingClientRect();
            const currentTop = boundingRect.top;
            const offset = averageVerticalPosition - currentTop;
            div.style.top = `${currentTop + offset}px`;
        }
    } else {
        console.error('Invalid axis parameter. Please use "horizontal" or "vertical".');
    }
}

/**
 * Clones all selected div elements and appends them to the div with the id "droppable".
 * Each cloned div is made draggable and is given a new unique id.
 * The "selected" class is added to each cloned div.
 * After cloning, all original divs are deselected.
 * The cloned divs are inserted right after the original divs.
 * A 'dragstop' event is bound to each cloned div, which calls the 'select' function when the div is done being dragged.
 */
function copyAndPasteDiv() {
    var allSelected = Array.from($('.selected'));
    deselectAll();
    allSelected.forEach(element => {
        // Clone the original DIV
        const newDiv = element.cloneNode(true);

        // Add the "selected" class to the new DIV
        newDiv.classList.add('selected');
        var newId = makeid();
        newDiv.id = newId;

        // Insert the new DIV right after the original DIV
        $('#droppable').append(newDiv);
        $(newDiv).draggable({grid: [1, 1]});
        $(newDiv).bind('dragstop', function () { select(this) });
    });

}

function deleteSelected() {
    $('.selected').remove();
}

function rotateSelected() {
    var allSelected = $('.selected');
    for (let index = 0; index < allSelected.length; index++) {
        const element = allSelected[index];
        var rotateByDeg = 45;
        var currentDeg = $(element).css("rotate");
        if (currentDeg == '360deg') {
            currentDeg = 'none';
        }
        if (currentDeg == 'none') {
            $(element).css("rotate", rotateByDeg + "deg");
        } else {
            currentDeg = currentDeg.match(/\d+/)[0];
            currentDeg.toString();
            var newDeg = Number(currentDeg) + Number(rotateByDeg);
            $(element).css("rotate", newDeg + "deg");
        }
    }

}
prepareEditor();