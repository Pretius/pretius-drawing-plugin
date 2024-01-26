var droppablePosition = $("#droppable").offset();
//console.log("Top: " + droppablePosition.top + ", Left: " + droppablePosition.left);
/**
 * Enables dragging functionality for components on mobile devices.
 */
function mobileDragComponents() {
  var box = $('.component.drag');
  for (let index = 0; index < box.length; index++) {
    const element = box[index];
    let clone = null;

    element.addEventListener('touchstart', function (e) {
      clone = element.cloneNode(true);
      clone.style.position = 'absolute';
      clone.style.opacity = '1';
      document.body.appendChild(clone);
    });

    element.addEventListener('touchmove', function (e) {
      var touchLocation = e.targetTouches[0];
      clone.style.left = touchLocation.pageX + 'px';
      clone.style.top = touchLocation.pageY + 'px';
    });

    element.addEventListener('touchend', function (e) {
      // Get the droppable div
      var droppableDiv = document.getElementById('droppable');
      var newId = makeid();

      clone.setAttribute('id', newId);
      clone.classList.add('remove');
      clone.classList.remove('drag');
      //Add input into DIV
      if ((clone.classList.contains("parking-space") || clone.classList.contains("parking-space-vertical")) && !clone.querySelector('.id-input')) {
        var input = document.createElement('textarea');
        input.setAttribute('type', 'text');
        input.setAttribute('placeholder', 'Enter text');
        input.classList.add('id-input');
        clone.appendChild(input);
      }
      // Remove the clone from the body
      document.body.removeChild(clone);

      // Append the clone to the droppable div
      droppableDiv.appendChild(clone);
      addDragToElement(clone);

      clone.style.left = (parseInt(clone.style.left) - droppablePosition.left) + 'px';
      clone.style.top = (parseInt(clone.style.top) - droppablePosition.top) + 'px';

      clone = null;
    });
  }
}
/**
 * Enables dragging functionality for existing components on mobile devices.
 */
function mobileDragExisitng() {
  var box = $('.remove.component');

  for (let index = 0; index < box.length; index++) {
    const element = box[index];
    addDragToElement(element);
  }
}
/**
 * Adds dragging functionality to a specific element on mobile devices.
 * @param {HTMLElement} element - The element to add dragging functionality to.
 */
function addDragToElement(element) {
  element.addEventListener('touchmove', function (e) {
    var touchLocation = e.targetTouches[0];
    element.style.left = (touchLocation.pageX - droppablePosition.left) + 'px';
    element.style.top = (touchLocation.pageY - droppablePosition.top) + 'px';
  })
}

function addMobileFunctionality() {
  mobileDragComponents();
  mobileDragExisitng();
}
