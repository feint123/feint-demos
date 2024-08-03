import { SVG } from "@svgdotjs/svg.js";

export class GraphApp {
  /**
   * 构造APP
   * @param {string} rootSelect
   */
  constructor(rootSelector) {
    /** @type HTMLDivElement */
    this.root = document.querySelector(rootSelector);
    this.rootSelector = rootSelector;
    /** @type VNode[] */
    this.vnodes = [];
    this.systemNodes = [];
    /** @type VNode[] */
    this.selectNodes = [];
    // 是否开始绘制选区
    this.startDrawSelectionArea = false;
    // 是否开启选区功能
    this.selectionEnable = false;
    // 是否开启连线功能
    this.connectionEnable = false;
    this.editEnable = false;
    this.viewPort = new VNode("graph-viewport");
  }
  /**
   * 开启编辑
   */
  enableEdit() {
    this.editEnable = true;
  }
  enableSelection(selection) {
    // 选区
    this.selectionEnable = true;
    const selectionArea = new Selection(
      "graph-selection" + new Date().getTime(),
    );
    selectionArea.size = { width: 0, height: 0 };
    selectionArea.position = { x: 0, y: 0 };
    selectionArea.hidden();
    this.selectionArea = selectionArea;
    this.addSystemNode(selectionArea);
  }
  /**
   * 开启连线功能
   * @param {VNode} connection
   */
  enableConnection(connection) {
    this.connectionEnable = true;
    const connectionNode = new Connection("graph-connection");
    connectionNode.size = { width: 0, height: 0 };
    connectionNode.position = { x: 0, y: 0 };
    this.connectionNode = connectionNode;
    this.connectionNode.hidden();
    this.addSystemNode(connectionNode);
    this.draw = SVG().addTo(this.rootSelector).size("100%", "100%");
  }
  enableMouse() {
    this.root.addEventListener("mousedown", (ev) => {
      // ev.preventDefault();
      if (ev.button === 0) {
        this.onMouseDown(ev);
      } else if (ev.button === 2) {
        this.vnodes.forEach((node) => (node.moveable = true));
        this.mouseDownPos = this.toInnerPosition(ev);
        this.mouseMovePos = this.mouseDownPos;
      }
    });
    this.root.addEventListener("contextmenu", (ev) => {
      ev.preventDefault();
    });
    this.root.addEventListener("mousemove", (ev) => {
      ev.preventDefault();
      this.onMouseMove(ev);
    });
    document.addEventListener("mouseup", (ev) => {
      ev.preventDefault();
      this.onMouseUp(ev);
    });
    document.addEventListener("dblclick", (ev) => {
      const selectNode = this.getTopInAreaNode(this.toInnerPosition(ev));
      if (selectNode) {
        // 输入组件控制
        this.startInput(selectNode);
      }
    });
  }

  /**
   * @param {(ev:KeyboardEvent)=>{}} userKeyDownCallback
   */
  enableKeyDown(userKeyDownCallback) {
    document.addEventListener("keydown", (ev) => {
      if (userKeyDownCallback) {
        userKeyDownCallback(ev);
        return;
      }
      // 删除以选择的节点
      if (ev.key === "Backspace") {
        const removeList = this.vnodes.filter((node) => node.selected);
        removeList.forEach((node) => this.removeNode(node));
        this.vnodes.forEach((node) => {
          node.connectToNodes = node.connectToNodes.filter(
            (conn) => !removeList.includes(conn),
          );
        });
        this.startDrawPreviewLine = false;
        if (this.connectionEnable) {
          // 删除箭头
          if (this.selectArrow) {
            console.log(
              this.selectArrow.from.connectToNodes,
              this.selectArrow.to,
            );
            this.selectArrow.from.connectToNodes =
              this.selectArrow.from.connectToNodes.splice(
                this.selectArrow.from.connectToNodes.includes(
                  this.selectArrow.to,
                ),
                1,
              );
          }
        }
        this.render();
      }
    });
  }

  onMouseDown(ev) {
    /** @type VNode[] */
    let inAreaNodes = [];
    /** @type VNode */
    let selectNode = null;
    this.mouseDownPos = this.toInnerPosition(ev);
    this.mouseMovePos = this.mouseDownPos;
    // 获取点击到的节点
    this.vnodes.forEach((node, index) => {
      if (node.inArea(this.mouseDownPos)) {
        inAreaNodes.push(node);
      }
    });
    // 如果点击的节点数>1,需要更具layer进行排序
    if (inAreaNodes.length > 1) {
      inAreaNodes = inAreaNodes.sort((a, b) => {
        return b.layer - a.layer;
      });
    }
    if (inAreaNodes.length > 0) {
      if (this.selectNodes.includes(inAreaNodes[0])) {
        this.selectNodes.forEach((node) => {
          node.moveable = true;
        });
      } else {
        this.selectNodes = [];
        selectNode = inAreaNodes[0];
        selectNode.selected = true;
        selectNode.moveable = true;
        // todo 更新节点的layer
        this.vnodes.splice(this.vnodes.indexOf(selectNode), 1);
        this.vnodes.push(selectNode);
        this.selectNodes.push(selectNode);
      }
    } else {
      // 绘制选区
      if (this.selectionEnable) {
        this.startDrawSelectionArea = true;
      }
      // 清空已选择的节点列表
      this.selectNodes = [];
      this.finishInput();
    }
    // 未被选择的节点
    this.vnodes
      .filter((value) => {
        return !this.selectNodes.includes(value);
      })
      .forEach((node) => {
        node.selected = false;
        node.moveable = false;
      });
    //
    if (this.connectionEnable) {
      // 开始进行连线
      if (
        this.connectionNode.inArea(this.mouseDownPos) &&
        this.connectionNode.visiable &&
        !this.startDrawPreviewLine
      ) {
        this.startDrawPreviewLine = true;
        this.startDrawSelectionArea = false;
        this.connectionDownPos = this.connectionNode.getCenter();
        this.connectionStartRect = this.connectionNode.getRect();
        this.connectionNode.moveable = false;
      }
      // 处理连线的选中事件
      this.hoverArrow(this.mouseDownPos);
      if (this.hoverArrowNodes.length > 0) {
        /** @type {{from:VNode, to:VNode}} */
        this.selectArrow = {
          from: this.hoverArrowNodes[0],
          to: this.hoverArrowNodes[1],
        };
      } else {
        this.selectArrow = null;
      }
    }
    this.render();
  }
  /**
   * 完成输入
   */
  finishInput() {
    if (this.editEnable && this.startInputing) {
      this.editNode.editable = false;
      this.startInputing = false;
    }
  }
  startInput(selectNode) {
    if (this.editEnable) {
      this.startInputing = true;
      this.editNode = selectNode;
      this.editNode.editable = true;
    }
  }
  clearInput() {
    // 清除其他节点的编辑状态
    this.vnodes.forEach((node) => (node.editable = false));
    this.startInputing = false;
  }
  /**
   * 处理鼠标移动
   * @param {MouseEvent} ev
   */
  onMouseMove(ev) {
    const innerPos = this.toInnerPosition(ev);
    this.vnodes
      .filter((value) => value.moveable)
      .forEach((node) => {
        node.shift({
          x: innerPos.x - this.mouseMovePos.x,
          y: innerPos.y - this.mouseMovePos.y,
        });
      });
    if (this.selectionEnable) {
      this.dealWithSelection(innerPos);
    }
    if (this.connectionEnable) {
      this.dealWithConnection(innerPos);
    }
    this.mouseMovePos = innerPos;
    this.render();
  }
  /**
   * 处理鼠标释放
   * @param {MouseEvent} ev
   */
  onMouseUp(ev) {
    this.vnodes.forEach((node) => {
      node.moveable = false;
    });
    const topNode = this.getTopInAreaNode(this.toInnerPosition(ev));
    if (topNode) {
      if (
        this.connectionEnable &&
        this.startDrawPreviewLine &&
        this.connectionNode.fromNode
      ) {
        this.connectionNode.fromNode.connectTo(topNode);
      }
    }
    this.startDrawSelectionArea = false;
    this.startDrawPreviewLine = false;
    this.selectionArea.hidden();
    this.render();
  }
  hoverArrow(currentPos) {
    this.hoverArrowNodes = [];
    this.vnodes.forEach((node) => {
      node.connectToNodes.forEach((connectNode) => {
        const startPoint = this.getIntersectionPos(
          node.getCenter(),
          connectNode.getCenter(),
          node.getRect(),
        );
        const endPoint = this.getIntersectionPos(
          connectNode.getCenter(),
          node.getCenter(),
          connectNode.getRect(),
        );
        const result = this.isPointInPolygon(
          currentPos,
          this.getBoundingBoxCoordinates(startPoint, endPoint, 16),
        );
        if (result) {
          this.hoverArrowNodes = [node, connectNode];
          return;
        }
      });
    });
  }
  /**
   * 处理鼠标移动过程中，连线功能的各种状态变化
   * @param {{x: number, y: number}} currentPos
   */
  dealWithConnection(currentPos) {
    /** @type VNode[] */
    let inAreaNodes = [];
    this.mouseHoverPos = currentPos;
    this.vnodes.forEach((node, index) => {
      let expand = { left: 0, right: 0, top: 0, bottom: 0 };
      if (this.connectionNode.visiable) {
        expand = { top: 32, bottom: 32, left: 32, right: 32 };
      }
      if (node.inArea(currentPos, expand)) {
        inAreaNodes.push(node);
      }
    });
    if (inAreaNodes.length > 1) {
      inAreaNodes = inAreaNodes.sort((a, b) => {
        return b.layer - a.layer;
      });
    }
    if (inAreaNodes.length > 0) {
      if (!this.startDrawPreviewLine) {
        // 展示连线节点
        this.connectionNode.show();
        this.connectionNode.resize(inAreaNodes[0].size);
        this.connectionNode.moveTo(inAreaNodes[0].getCenter());
        this.connectionNode.fromNode = inAreaNodes[0];
      } else {
        if (this.connectionNode.fromNode.id != inAreaNodes[0].id) {
          inAreaNodes[0].highlight = true;
        }
      }
    } else {
      this.connectionNode.hidden();
      this.vnodes.forEach((node) => (node.highlight = false));
    }
    if (this.connectionNode.visiable) {
      if (this.connectionNode.inArea(currentPos)) {
        this.connectionNode.connectable = true;
      } else {
        this.connectionNode.connectable = false;
      }
    }
    // 箭头交互处理
    this.hoverArrow(currentPos);
  }
  /**
   * 处理选区
   * @param {{x:number, y: number}} currentPos
   */
  dealWithSelection(currentPos) {
    if (this.startDrawSelectionArea) {
      this.selectionArea.position = {
        x: Math.min(this.mouseDownPos.x, currentPos.x),
        y: Math.min(this.mouseDownPos.y, currentPos.y),
      };
      this.selectionArea.size = {
        width: Math.abs(currentPos.x - this.mouseDownPos.x),
        height: Math.abs(currentPos.y - this.mouseDownPos.y),
      };
      this.selectionArea.show();
      this.vnodes.forEach((node) => {
        if (this.selectionArea.inArea(node.getRect())) {
          if (!this.selectNodes.includes(node)) {
            node.selected = true;
            this.selectNodes.push(node);
          }
        } else if (this.selectNodes.includes(node)) {
          node.selected = false;
          this.selectNodes.splice(this.selectNodes.indexOf(node), 1);
        }
      });
    }
  }
  /**
   * 添加节点
   * @param {VNode} vnode
   */
  addNode(vnode) {
    this.vnodes.push(vnode);
    this.root.appendChild(vnode.rootElement);
  }
  /**
   * 移除节点
   * @param {VNode} vnode
   */
  removeNode(vnode) {
    if (vnode) {
      this.vnodes.splice(this.vnodes.indexOf(vnode), 1);
      this.root.removeChild(vnode.rootElement);
    }
  }
  /**
   * 添加系统节点
   * @param {VNode} vnode
   */
  addSystemNode(vnode) {
    this.systemNodes.push(vnode);
    this.root.appendChild(vnode.rootElement);
  }
  /**
   * 转换成内部坐标系
   * @param {{x:number, y:number}} pos
   * @returns {{x:number, y:number}}
   */
  toInnerPosition(pos) {
    return {
      x: pos.x - this.root.getBoundingClientRect().left,
      y: pos.y - this.root.getBoundingClientRect().top,
    };
  }
  /**
   * 获取两点连线与矩形边框的交点坐标
   * @param {{x:number, y: number}} pos1
   * @param {{x: number, y:number}} pos2
   * @param {{x:number, y:number, width:number, height: number}} rect
   * @returns {{x: number, y: number}}
   */
  getIntersectionPos(pos1, pos2, rect) {
    const offset = 8;
    // 计算连线的斜率
    const m = (pos2.y - pos1.y) / (pos2.x - pos1.x);
    const inteLeft = m * (rect.x - pos1.x) + pos1.y;
    const inteRight = m * (rect.x + rect.width - pos1.x) + pos1.y;
    const inteTop = (rect.y - pos1.y) / m + pos1.x;
    const inteBottom = (rect.y + rect.height - pos1.y) / m + pos1.x;
    if (
      rect.y <= inteLeft &&
      inteLeft <= rect.y + rect.height &&
      pos2.x < rect.x
    ) {
      return { x: rect.x - offset, y: inteLeft };
    }
    if (rect.y <= inteRight && inteRight <= rect.y + rect.height) {
      return { x: rect.x + rect.width + offset, y: inteRight };
    }
    if (
      rect.x <= inteTop &&
      inteTop <= rect.x + rect.width &&
      pos2.y < rect.y
    ) {
      return { x: inteTop, y: rect.y - offset };
    }
    if (rect.x <= inteBottom && inteBottom <= rect.x + rect.width) {
      return { x: inteBottom, y: rect.y + rect.height + offset };
    }
  }
  /**
   * 获取区域内最顶部的节点
   * @param {{x:number, y:number}} pos
   * @returns {VNode | null}
   */
  getTopInAreaNode(pos) {
    let inAreaNodes = [];
    // 获取点击到的节点
    this.vnodes.forEach((node, index) => {
      if (node.inArea(pos)) {
        inAreaNodes.push(node);
      }
    });
    // 如果点击的节点数>1,需要更具layer进行排序
    if (inAreaNodes.length > 1) {
      inAreaNodes = inAreaNodes.sort((a, b) => {
        return b.layer - a.layer;
      });
    }
    if (inAreaNodes.length > 0) {
      return inAreaNodes[0];
    } else {
      return null;
    }
  }
  /**
   *
   * @param {{x: number, y: number}} point
   * @param {{x: number, y: number}[]} polygon
   * @returns
   */
  isPointInPolygon(point, polygon) {
    let inside = false;
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      const intersect =
        polygon[i].y > point.y !== polygon[j].y > point.y &&
        point.x <
          ((polygon[j].x - polygon[i].x) * (point.y - polygon[i].y)) /
            (polygon[j].y - polygon[i].y) +
            polygon[i].x;

      if (intersect) inside = !inside;
    }
    return inside;
  }
  /**
   * 获取包含连线的矩形区域
   * @param {{x:number, y:number}} p1
   * @param {{x:number, y:number}} p2
   * @param {{x:number, y:number}[]} lineWidth
   * @returns
   */
  getBoundingBoxCoordinates(p1, p2, lineWidth) {
    // 计算直线的方向向量
    const dx = p2.x - p1.x;
    const dy = p2.y - p1.y;

    // 计算直线长度
    const length = Math.sqrt(dx * dx + dy * dy);

    // 计算单位方向向量
    const unitDx = dx / length;
    const unitDy = dy / length;

    // 计算法向量（垂直向量），通过交换dx和dy并改变其中一个的符号来获得
    const normalDx = -unitDy;
    const normalDy = unitDx;

    // 计算半宽
    const halfLineWidth = lineWidth / 2;

    // 计算矩形的4个角点
    const x1Offset = normalDx * halfLineWidth;
    const y1Offset = normalDy * halfLineWidth;
    const x2Offset = normalDx * halfLineWidth;
    const y2Offset = normalDy * halfLineWidth;

    const topLeft = { x: p1.x - x1Offset, y: p1.y - y1Offset };
    const topRight = { x: p1.x + x1Offset, y: p1.y + y1Offset };
    const bottomLeft = { x: p2.x - x2Offset, y: p2.y - y2Offset };
    const bottomRight = { x: p2.x + x2Offset, y: p2.y + y2Offset };

    return [topLeft, topRight, bottomRight, bottomLeft];
  }

  /**
   * 将图结构转换成json数据
   * @returns {string}
   */
  getData() {}

  /**
   * 渲染App
   */
  render() {
    this.draw.clear();
    this.root.style.position = "relative";
    this.draw.style.zIndex = 10;
    let hasHoverArrow = false;
    // 渲染系统节点
    this.systemNodes.forEach((node) => {
      node.render();
    });
    this.vnodes.forEach((node, index) => {
      node.layer = index + 1000;
      node.render();
      // this.draw
      //   .foreignObject(node.size.width, node.size.height)
      //   .add(SVG(node.rootElement));
      // 渲染连接线
      if (this.connectionEnable) {
        node.connectToNodes.forEach((connectNode) => {
          const startPoint = this.getIntersectionPos(
            node.getCenter(),
            connectNode.getCenter(),
            node.getRect(),
          );
          const endPoint = this.getIntersectionPos(
            connectNode.getCenter(),
            node.getCenter(),
            connectNode.getRect(),
          );
          if (startPoint && endPoint) {
            const line = this.draw.line(
              startPoint.x,
              startPoint.y,
              endPoint.x,
              endPoint.y,
            );

            if (
              this.selectArrow &&
              this.selectArrow.from.id === node.id &&
              this.selectArrow.to.id === connectNode.id
            ) {
              line
                .stroke({ color: "blue", width: 4 })
                .marker("end", 5, 4, function (add) {
                  add.ref(4, 2).path("M 0 0 L 5 2 L 0 4 z").fill("blue");
                });
            } else {
              line
                .stroke({ color: "black", width: 2 })
                .marker("end", 5, 4, function (add) {
                  add.ref(4, 2).path("M 0 0 L 5 2 L 0 4 z").fill("black");
                });
            }
            if (
              this.hoverArrowNodes &&
              this.hoverArrowNodes.length === 2 &&
              this.hoverArrowNodes[0].id === node.id &&
              this.hoverArrowNodes[1].id === connectNode.id
            ) {
              hasHoverArrow = true;
            }
            // 显示debug内容
            if (this.openDebug) {
              const list = this.getBoundingBoxCoordinates(
                startPoint,
                endPoint,
                16,
              );
              this.draw
                .polygon([
                  list[0].x,
                  list[0].y,
                  list[1].x,
                  list[1].y,
                  list[2].x,
                  list[2].y,
                  list[3].x,
                  list[3].y,
                ])
                .fill("#aaaaaacc");
            }
          }
        });
      }
    });
    if (this.connectionEnable) {
      if (hasHoverArrow) {
        this.root.style.cursor = "grab";
      } else {
        this.root.style.cursor = "default";
      }

      if (this.startDrawPreviewLine) {
        const intePos = this.getIntersectionPos(
          this.connectionDownPos,
          this.mouseMovePos,
          this.connectionStartRect,
        );
        this.draw
          .line(intePos.x, intePos.y, this.mouseMovePos.x, this.mouseMovePos.y)
          .stroke({ color: "#00f", width: 2, opacity: 0.5 })
          .marker("end", 5, 4, function (add) {
            add.ref(4, 2).path("M 0 0 L 5 2 L 0 4 z").fill("#00f");
          });
      }
    }
  }
}
/**
 * 虚拟节点
 */
export class VNode {
  /**
   *
   * @param {string} id
   */
  constructor(id) {
    this.content = "";
    this.layer = 0;
    this.size = { width: 10, height: 10 };
    this.position = { x: 0, y: 0 };
    this.id = id;
    this.rootElement = document.createElement("div");
    this.rootElement.id = `vnode-${id}`;
    this.moveable = false;
    this.resizable = false;
    this.selected = false;
    this.visiable = true;
    this.highlight = false;
    /** @type VNode[] */
    this.connectToNodes = [];
    this.parentNodes = [];
  }
  /**
   * 渲染节点
   */
  render() {}
  /**
   * 获取节点数据
   * @returns {{}}
   */
  getData() {}
  /**
   * 只执行一次
   */
  renderOnce() {}
  /**
   * 获取节点左侧位置的坐标
   * @returns {{x:number, y:number}}
   */
  getLeft() {
    return { x: this.position.x, y: this.position.y + this.getHeight() / 2 };
  }
  /**
   * 获取节点右侧位置的坐标
   * @returns {{x:number, y:number}}
   */
  getRight() {
    return {
      x: this.position.x + this.getWidth(),
      y: this.position.y + this.getHeight() / 2,
    };
  }
  /**
   * @returns {number}
   */
  getWidth() {
    return Math.max(this.rootElement.clientWidth, this.size.width);
  }

  /**
   * @returns {number}
   */
  getHeight() {
    return Math.max(this.rootElement.clientHeight, this.size.height);
  }
  /**
   * 获取节点顶部位置的坐标
   * @returns {{x:number, y:number}}
   */
  getUp() {}
  /**
   * 获取节点底部位置的坐标
   * @returns {{x:number, y:number}}
   */
  getDown() {}
  /**
   * 获取节点中心位置的坐标
   * @returns {{x:number, y:number}}
   */
  getCenter() {
    return {
      x: this.position.x + this.getWidth() / 2,
      y: this.position.y + this.getHeight() / 2,
    };
  }
  /**
   * 获取节点的边界
   * @returns {{x: number, y: number, width: number, height: number}}
   */
  getRect() {
    return {
      x: this.position.x,
      y: this.position.y,
      width: this.getWidth(),
      height: this.getHeight(),
    };
  }
  /**
   * 将当前节点移动到指定位置
   * @param {{x:number, y:number}} pos
   */
  moveTo(pos) {
    this.position = {
      x: pos.x - this.getWidth() / 2,
      y: pos.y - this.getHeight() / 2,
    };
  }
  /**
   * 基于节点当前位置移动
   * @param {{x: number, y:number}} vec
   */
  shift(vec) {
    this.position = { x: this.position.x + vec.x, y: this.position.y + vec.y };
  }
  /**
   * 修改节点的尺寸
   * @param {{width:number, height:number}} size
   */
  resize(size) {
    this.size = size;
  }
  updateByPhysicSize() {
    this.size = this.rootElement.getBoundingClientRect();
    console.log(this.size);
  }
  /**
   * 判断输入点是否在节点的作用范围内
   * @param {{x:number, y:number}} point
   * @param {{left: number, right: number, top: number, bottom: number}} expand
   * @returns {boolean}
   */
  inArea(point, expand = { left: 0, right: 0, top: 0, bottom: 0 }) {
    if (
      point.x > this.position.x - expand.left &&
      point.y > this.position.y - expand.right &&
      point.x < this.position.x + this.getWidth() + expand.right &&
      point.y < this.position.y + this.getHeight() + expand.bottom
    ) {
      return true;
    } else {
      return false;
    }
  }
  /**
   * 隐藏节点
   */
  hidden() {
    this.visiable = false;
  }
  /**
   * 展示节点
   */
  show() {
    this.visiable = true;
  }
  /**
   *
   * @param {VNode} node
   */
  connectTo(node) {
    this.connectToNodes.push(node);
    node.parentNodes.push(this);
  }
}

export class Rectangle extends VNode {
  constructor(id) {
    super(id);
    this.renderOnce();
  }
  renderOnce() {
    this.rootElement.style.backgroundColor = "#eee";
    this.rootElement.style.borderRadius = "4px";
    this.rootElement.style.position = "absolute";
  }

  render() {
    this.rootElement.style.width = this.size.width + "px";
    this.rootElement.style.height = this.size.height + "px";
    this.rootElement.style.top = this.position.y + "px";
    this.rootElement.style.left = this.position.x + "px";
    this.rootElement.style.zIndex = this.layer;
    this.rootElement.style.fontSize = "14px";
    if (this.visiable) {
      this.rootElement.style.display = "flex";
      this.rootElement.focus();
    } else {
      this.rootElement.style.display = "none";
    }
    if (this.highlight) {
      this.rootElement.style.border = "8px solid #0000ff44";
      this.rootElement.style.left = this.position.x - 8 + "px";
      this.rootElement.style.top = this.position.y - 8 + "px";
    } else if (this.selected) {
      this.rootElement.style.border = "2px solid blue";
      this.rootElement.style.top = this.position.y - 2 + "px";
      this.rootElement.style.left = this.position.x - 2 + "px";
    } else {
      this.rootElement.style.border = "none";
    }
  }
}

export class Selection extends Rectangle {
  render() {
    super.render();
    this.rootElement.style.backgroundColor = "#0000ff11";
    this.rootElement.style.border = "1px dashed blue";
    this.rootElement.style.zIndex = 10000;
  }
  /**
   * 校验是否在选取范围内
   * @param {{x: number, y: number, width: number, height: number}} rect
   * @returns {boolean}
   */
  inArea(rect) {
    if (
      rect.x > this.position.x &&
      rect.y > this.position.y &&
      rect.width + rect.x < this.position.x + this.size.width &&
      rect.height + rect.y < this.position.y + this.size.height
    ) {
      return true;
    } else {
      return false;
    }
  }
}

/**
 * 连线节点
 */
export class Connection extends VNode {
  constructor(id) {
    super(id);
    this.renderOnce();
  }
  renderOnce() {
    this.indicatorSize = { width: 8, height: 8 };
    const centerDiv = document.createElement("div");
    const upIndicatorDiv = document.createElement("div");
    const downIndicatorDiv = document.createElement("div");
    const leftIndicatorDiv = document.createElement("div");
    const rightIndicatorDiv = document.createElement("div");
    this.rootElement.style.position = "absolute";
    this.rootElement.style.transition = "opacity 0.2s ease-in";
    this.rootElement.style.zIndex = 1;
    // centerDiv.style.border = "1px solid blue";
    upIndicatorDiv.style.top = "-16px";
    downIndicatorDiv.style.bottom = -16 + "px";
    leftIndicatorDiv.style.left = "-16px";
    rightIndicatorDiv.style.right = -16 + "px";

    this.styledIndicator(upIndicatorDiv);
    this.styledIndicator(downIndicatorDiv);
    this.styledIndicator(leftIndicatorDiv);
    this.styledIndicator(rightIndicatorDiv);
    this.rootElement.appendChild(centerDiv);
    this.rootElement.appendChild(upIndicatorDiv);
    this.rootElement.appendChild(downIndicatorDiv);
    this.rootElement.appendChild(leftIndicatorDiv);
    this.rootElement.appendChild(rightIndicatorDiv);
    this.centerDiv = centerDiv;
    this.upIndicatorDiv = upIndicatorDiv;
    this.downIndicatorDiv = downIndicatorDiv;
    this.leftIndicatorDiv = leftIndicatorDiv;
    this.rightIndicatorDiv = rightIndicatorDiv;
  }
  /**
   *
   * @param {HTMLDivElement} indicatorDiv
   */
  styledIndicator(indicatorDiv) {
    indicatorDiv.style.width = this.indicatorSize.width + "px";
    indicatorDiv.style.height = this.indicatorSize.height + "px";
    indicatorDiv.style.backgroundColor = "blue";
    indicatorDiv.style.borderRadius = "4px";
    indicatorDiv.style.position = "absolute";
    indicatorDiv.style.opacity = 0.5;
    indicatorDiv.classList.add("indicator");
  }
  render() {
    this.centerDiv.style.width = this.size.width + "px";
    this.centerDiv.style.height = this.size.height + "px";
    this.rootElement.style.left = this.position.x + "px";
    this.rootElement.style.top = this.position.y + "px";
    if (this.visiable) {
      this.rootElement.style.opacity = 1;
    } else {
      this.rootElement.style.opacity = 0;
    }

    this.rootElement.querySelectorAll(".indicator").forEach((element) => {
      if (this.connectable) {
        element.style.opacity = 1;
      } else if (this.visiable) {
        element.style.opacity = 0.5;
      } else {
        element.style.opacity = 0;
      }
    });

    this.upIndicatorDiv.style.left =
      this.size.width / 2 - this.indicatorSize.width / 2 + "px";
    this.downIndicatorDiv.style.left =
      this.size.width / 2 - this.indicatorSize.width / 2 + "px";
    this.leftIndicatorDiv.style.top =
      this.size.height / 2 - this.indicatorSize.height / 2 + "px";
    this.rightIndicatorDiv.style.top =
      this.size.height / 2 - this.indicatorSize.height / 2 + "px";
  }
  /**
   * @param {{x: number, y: number}} point
   */
  inArea(point) {
    if (
      (point.x > this.position.x - 32 && point.x < this.position.x) ||
      (point.y > this.position.y - 32 && point.y < this.position.y) ||
      (point.x < this.position.x + this.size.width + 32 &&
        point.x > this.position.x + this.size.width) ||
      (point.y < this.position.y + this.size.height + 32 &&
        point.y > this.position.y + this.size.height)
    ) {
      return true;
    } else {
      return false;
    }
  }
}

export class MindNode extends Rectangle {
  constructor(id, level) {
    super(id);
    this.editable = false;
    this.level = level;
    this.renderOnce();
  }

  renderOnce() {
    super.renderOnce();
    this.size = { width: 180, height: 22 };
    this.rootElement.style.alignItems = "center";
    this.rootElement.style.textAlign = "left";
    this.rootElement.style.minHeight =
      Math.max(this.size.height - this.level * 2, 14) + "px";
    this.rootElement.style.minWidth = "100px";
    this.rootElement.style.maxWidth = this.size.width + "px";
    this.rootElement.style.padding = "8px";
    const colors = ["red", "orange", "green", "blue"];
    this.rootElement.style.backgroundColor = colors[this.level % 4];
    this.rootElement.style.color = "white";
    this.rootElement.style.fontSize = Math.max(20 - this.level * 2, 10) + "px";
    this.rootElement.style.borderRadius = "8px";
    this.rootElement.style.wordBreak = "break-words";
    this.rootElement.style.whiteSpace = "pre-wrap";
  }

  getWidth() {
    return this.rootElement.clientWidth;
  }
  /**
   * 设置文本内容
   * @param {string} content
   */
  setContent(content) {
    this.rootElement.innerText = content;
  }
  render() {
    if (this.selected) {
      this.rootElement.style.borderColor = "#000";
    }
    if (this.editable) {
      this.rootElement.contentEditable = true;
      this.rootElement.focus();
    } else {
      this.rootElement.contentEditable = false;
    }
    this.rootElement.style.top = this.position.y + "px";
    this.rootElement.style.left = this.position.x + "px";
    this.rootElement.style.zIndex = this.layer;
    if (this.selected) {
      this.rootElement.style.border = "2px solid blue";
      this.rootElement.style.top = this.position.y - 2 + "px";
      this.rootElement.style.left = this.position.x - 2 + "px";
    } else {
      this.rootElement.style.border = "none";
    }
  }
  getData() {
    return {
      content: this.rootElement.innerText,
      level: this.level,
      id: this.id,
      position: this.position,
      children: this.connectToNodes.map((node) => node.getData()),
    };
  }
}

export class MindApp extends GraphApp {
  constructor(rootSelector, dataString) {
    super(rootSelector);
    if (dataString) {
      const dataList = JSON.parse(dataString);
      if (dataList) {
        dataList.forEach((node) => {
          const rootNode = this.recoverData(node);
          this.addNode(rootNode);
        });
      }
    }
  }
  /**
   * 恢复图结构
   * @param {{id: string, level:number, content: string, position:{x:number, y: number}, children:[]}} dataObj
   */
  recoverData(dataObj) {
    const mindNode = new MindNode(dataObj.id, dataObj.level);
    mindNode.setContent(dataObj.content);
    mindNode.position = dataObj.position;
    if (dataObj.children) {
      dataObj.children.forEach((ch) => {
        const childNode = this.recoverData(ch);
        this.addNode(childNode);
        mindNode.connectTo(childNode);
      });
    }
    return mindNode;
  }
  getData() {
    const dataList = this.vnodes
      .filter((node) => node.level === 0)
      .map((node) => node.getData());
    return JSON.stringify(dataList);
  }
  render() {
    this.draw.clear();
    const colors = ["red", "orange", "green", "blue"];
    this.root.style.position = "relative";
    this.connectionNode.hidden();
    this.systemNodes.forEach((node) => node.render());
    this.vnodes
      .filter((node) => node.level === 0)
      .forEach((node) => {
        this.recursionMindNodes(node);
      });
    // 连接节点
    this.vnodes.forEach((node, index) => {
      node.render();
      // 渲染连接线
      node.connectToNodes.forEach((connectNode, index) => {
        const startPoint = node.getRight();
        const endPoint = connectNode.getLeft();
        if (startPoint && endPoint) {
          const line = this.draw.path(
            `M ${startPoint.x} ${startPoint.y} Q ${startPoint.x + (endPoint.x - startPoint.x) / 2} ${startPoint.y + (endPoint.y - startPoint.y)} ${endPoint.x} ${endPoint.y}`,
          );
          line.fill("#00000000").stroke({
            color: colors[node.level % 4],
            width: Math.max(2, 8 - node.level * 2),
            linecap: "round",
          });
        }
        // this.draw
        //   .foreignObject(node.getWidth(), node.getHeight())
        //   .add(SVG(node.rootElement));
      });
    });
    this.vnodes.forEach((node) => {
      if (this.selectNodes.includes(node)) {
        node.selected = true;
      } else {
        node.selected = false;
      }
      node.render();
    });
  }
  /**
   * 计算当前节点子树的最终高度
   * @param {VNode} parent
   */
  calcTotalHeight(parent) {
    const gap = 20;
    const subNodeSize = parent.connectToNodes.length;
    let subHeight = 0;
    if (parent.connectToNodes.length > 0) {
      subHeight =
        parent.connectToNodes
          .map((node) => this.calcTotalHeight(node))
          .reduce((pre, cur) => pre + cur) +
        (subNodeSize - 1) * gap;
    }
    return Math.max(parent.getHeight(), subHeight);
  }
  /**
   * 递归布局每一个节点的位置
   * @param {MindNode} parent
   */
  recursionMindNodes(parent) {
    if (parent.connectToNodes.length == 0) {
      return 0;
    }
    const gap = 20;
    const totalHeight = this.calcTotalHeight(parent);
    let currentHeight = 0;
    // for (node, index) in parent.connectToNodes
    parent.connectToNodes.forEach((node, index) => {
      const subHeight = Math.max(node.getHeight(), this.calcTotalHeight(node));
      currentHeight = currentHeight + subHeight / 2;
      node.moveTo({
        x: 0,
        y:
          parent.position.y -
          totalHeight / 2 +
          parent.getHeight() / 2 +
          currentHeight,
      });
      node.position.x = parent.position.x + parent.getWidth() + 64;
      currentHeight = currentHeight + gap + subHeight / 2;
      this.recursionMindNodes(node);
    });
  }
}
