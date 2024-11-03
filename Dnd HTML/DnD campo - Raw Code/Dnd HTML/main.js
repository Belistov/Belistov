let selectedObject = 'tree';

function createMap() {
  const width = parseInt(document.getElementById('map-width').value);
  const height = parseInt(document.getElementById('map-height').value);
  const mapGrid = document.getElementById('map-grid');

  // Set the grid dimensions
  mapGrid.innerHTML = '';
  mapGrid.style.gridTemplateColumns = `repeat(${width}, 40px)`;
  mapGrid.style.gridTemplateRows = `repeat(${height}, 40px)`;

  // Create cells for the map
  for (let i = 0; i < width * height; i++) {
    const cell = document.createElement('div');
    cell.classList.add('map-cell');
    cell.dataset.object = '0'; // Default is empty
    cell.addEventListener('click', () => placeObject(cell));
    mapGrid.appendChild(cell);
  }
}

function selectObject(object) {
  selectedObject = object;
}

function placeObject(cell) {
  // Clear previous object class if exists
  cell.classList.remove('tree', 'chest', 'wall');
  cell.dataset.object = '0';

  // Add new object class and update dataset
  if (selectedObject) {
    cell.classList.add(selectedObject);
    cell.dataset.object = selectedObject === 'wall' ? '1' : selectedObject;
  }
}

function copyMapData() {
  const mapGrid = document.getElementById('map-grid');
  const cells = Array.from(mapGrid.children);
  const width = parseInt(document.getElementById('map-width').value);

  // Format map data as rows
  const rows = [];
  for (let i = 0; i < cells.length; i += width) {
    const row = cells.slice(i, i + width).map(cell => cell.dataset.object);
    rows.push(`(${row.join(",")})`);
  }

  // Join rows into final map data format
  const mapData = rows.join(",");

  // Copy to clipboard
  navigator.clipboard.writeText(mapData).then(() => {
    alert("Map data copied to clipboard!");
  }).catch(err => {
    console.error("Error copying map data: ", err);
  });
}

function loadMapData() {
  const mapDataInput = document.getElementById('map-data-input').value.trim();

  // Parse rows by splitting at commas and parentheses
  const rows = mapDataInput.match(/\(([^)]+)\)/g);
  if (!rows) {
    alert("Invalid map data format. Please check the input.");
    return;
  }

  const mapGrid = document.getElementById('map-grid');
  const height = rows.length;
  const width = rows[0].replace(/[()]/g, "").split(",").length;

  // Update map dimensions
  document.getElementById('map-width').value = width;
  document.getElementById('map-height').value = height;
  createMap();

  // Apply parsed data to the grid cells
  const cells = Array.from(mapGrid.children);
  let cellIndex = 0;

  rows.forEach(row => {
    const items = row.replace(/[()]/g, "").split(",");

    items.forEach(item => {
      const cell = cells[cellIndex++];
      cell.classList.remove('tree', 'chest', 'wall');
      cell.dataset.object = item;

      if (item === '1') {
        cell.classList.add('wall');
      } else if (item === 'tree') {
        cell.classList.add('tree');
      } else if (item === 'chest') {
        cell.classList.add('chest');
      }
    });
  });
}
