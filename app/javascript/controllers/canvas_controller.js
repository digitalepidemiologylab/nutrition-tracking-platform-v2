import { ApplicationController } from 'stimulus-use';
import { patch, destroy } from '@rails/request.js';
import PolyBool from 'polybooljs';
import contrastColors from '../contrast_colors';

export default class extends ApplicationController {
  static get values() {
    return {
      polygons: Array,
      annotationItemId: String,
      polygonSetUrl: String,
    };
  }

  connect() {
    window.addEventListener('resize', () => { this.initializeCanvas(); }, { capture: true });
  }

  initializeCanvas() {
    const canvasElement = this.element;
    const parent = canvasElement.closest('div');
    // We cannot get the parent when resizing the window after selecting another annotation_item
    if (parent) {
      canvasElement.width = parent.offsetWidth;
      canvasElement.height = parent.offsetWidth;
      const ctx = canvasElement.getContext('2d');

      // let's clear it
      ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);

      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';

      this.drawPolygons(ctx);
      this.drawNewPolygonsWithMouse(ctx);
    }
  }

  drawPolygons(ctx) {
    if (this.hasPolygonsValue) {
      const selectedPolygons = this.polygonsValue.find((data) => data.id === this.annotationItemIdValue);
      const existingPolygons = this.polygonsValue
        .filter((data) => data.id !== this.annotationItemIdValue)
        .sort((a, b) => a.index - b.index);
      if (selectedPolygons) {
        existingPolygons.push(selectedPolygons);
      }
      existingPolygons.forEach((polygonData) => {
        const { id, colorIndex } = polygonData;
        let { polygons } = polygonData;
        if (polygons && polygons.length) {
          if (polygons.length > 1) {
            polygons = this.mergePolygons(polygons);
          }
          let contrast = 80;
          let lineDash = [5, 15];
          if (id === this.annotationItemIdValue) {
            contrast = 100;
            lineDash = [];
          }
          ctx.setLineDash(lineDash);
          this.drawPolygon(ctx, polygons, contrastColors[colorIndex], contrast);
        }
      });
      ctx.setLineDash([]);
    }
  }

  drawPolygon(ctx, polygons, color, opacity) {
    const { canvas } = ctx;
    const { width, height } = canvas;
    ctx.beginPath();
    ctx.strokeStyle = `${color}${opacity === 100 ? '' : opacity}`;
    ctx.fillStyle = `${color}${opacity - 60}`;
    ctx.lineWidth = 5;
    const mergedPolygons = this.mergePolygons(polygons);
    mergedPolygons.forEach((polygon) => {
      const firstPoint = polygon.shift();
      ctx.moveTo(firstPoint[0] * width, firstPoint[1] * height);
      polygon.forEach((coord) => {
        ctx.lineTo(coord[0] * width, coord[1] * height);
      });
      ctx.closePath();
    });
    ctx.fill();
    ctx.stroke();
  }

  drawNewPolygonsWithMouse(ctx) {
    if (this.hasAnnotationItemIdValue && this.annotationItemIdValue !== '') {
      const { canvas } = ctx;
      const { width } = canvas;
      let clicked = 0;
      let previousCoordinate;
      let polygonData = this.polygonsValue.find((data) => data.id === this.annotationItemIdValue);
      if (!polygonData) {
        polygonData = {
          id: this.annotationItemIdValue,
          polygons: [],
        };
      }
      const { colorIndex } = polygonData;
      let polygons = polygonData.polygons || [];
      let polygon = [];
      ctx.strokeStyle = contrastColors[colorIndex];
      ctx.fillStyle = `${contrastColors[colorIndex]}80`;
      ctx.lineWidth = 5;

      const move = (e) => {
        if (clicked === 0) return;

        const [canvasX, canvasY] = this.getOffset(canvas);
        const x = e.pageX - canvasX;
        const y = e.pageY - canvasY;
        // here we record the coordinate only if it's not
        // too close from previous one
        if (Math.abs(x - previousCoordinate[0]) + Math.abs(y - previousCoordinate[1]) > (width / 50)) {
          ctx.lineTo(x, y);
          ctx.stroke();
          polygon.push(this.relativeCoordinates(ctx, x, y));
          previousCoordinate = [x, y];
        }
      };
      const stop = () => {
        if (clicked === 0) return;

        ctx.closePath();
        ctx.stroke();
        ctx.fill();
        clicked = 0;
        polygons.push(polygon);
        if (polygons.length > 1) {
          polygons = this.mergePolygons(polygons);
        }
        const newPolygonData = { ...polygonData, polygons };
        const existingPolygons = this.polygonsValue
          .filter((data) => data.id !== this.annotationItemIdValue);
        existingPolygons.push(newPolygonData);
        this.polygonsValue = existingPolygons;
        this.savePolygons(polygons);
        polygon = [];
        canvas.removeEventListener('mousemove', move, false);
        window.removeEventListener('mousedown', stop, false);
      };
      const start = (e) => {
        canvas.onmousemove = move;
        window.onmouseup = stop;

        const [canvasX, canvasY] = this.getOffset(canvas);
        clicked = 1;
        const x = e.pageX - canvasX;
        const y = e.pageY - canvasY;
        ctx.beginPath();
        ctx.moveTo(x, y);
        polygon.push(this.relativeCoordinates(ctx, x, y));
        previousCoordinate = [x, y];
      };
      canvas.onmousedown = start;
    }
  }

  savePolygons(polygons) {
    const url = this.polygonSetUrlValue;
    patch(url, {
      body: {
        polygon_set: {
          polygons: JSON.stringify(polygons),
        },
      },
      responseKind: 'turbo-stream',
    });
  }

  destroyPolygons() {
    if (this.hasAnnotationItemIdValue && this.hasPolygonSetUrlValue) {
      const selectedPolygons = this.polygonsValue.find((data) => data.id === this.annotationItemIdValue);
      const existingPolygons = this.polygonsValue
        .filter((data) => data.id !== this.annotationItemIdValue)
        .sort((a, b) => a.index - b.index);
      const newPolygonData = { ...selectedPolygons, polygons: null };
      existingPolygons.push(newPolygonData);
      this.polygonsValue = existingPolygons;
      destroy(this.polygonSetUrlValue, {
        responseKind: 'turbo-stream',
      });
    }
  }

  getOffset(el) {
    const rect = el.getBoundingClientRect();
    return [rect.left + window.scrollX, rect.top + window.scrollY];
  }

  relativeCoordinates(ctx, x, y) {
    const { canvas } = ctx;
    const { width, height } = canvas;
    return [parseFloat((x / width).toFixed(6)), parseFloat((y / height).toFixed(6))];
  }

  mergePolygons(polygons) {
    // leverages the polybooljs library to merge polygons
    const polyBools = polygons.map((polygon) => ({
      regions: [polygon],
      inverted: false,
    }));
    let segments = PolyBool.segments(polyBools[0]);
    polyBools.forEach((polyBool) => {
      const segments2 = PolyBool.segments(polyBool);
      const comb = PolyBool.combine(segments, segments2);
      segments = PolyBool.selectUnion(comb);
    });
    return PolyBool.polygon(segments).regions;
  }

  setAnnotationItemId(annotationItemIdValue, polygonSetUrlValue) {
    this.annotationItemIdValue = annotationItemIdValue;
    this.polygonSetUrlValue = polygonSetUrlValue;
    this.initializeCanvas();
  }

  polygonsValueChanged() {
    this.initializeCanvas();
  }
}
