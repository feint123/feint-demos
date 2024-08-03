<script>
    import { GraphApp, VNode, MindNode, MindApp, Rectangle } from "./index.js";
    let mindApp;
    document.addEventListener("DOMContentLoaded", () => {
        const app = new GraphApp(".app");
        app.enableMouse();
        app.enableKeyDown();
        app.enableSelection();
        app.enableConnection();
        app.root.addEventListener("dblclick", (ev) => {
            const node = new Rectangle(new Date().getTime());
            node.size = { width: 100, height: 40 };
            node.moveTo(app.toInnerPosition(ev));
            app.addNode(node);
            app.render();
        });

        const history = window.localStorage.getItem("mind-data");
        mindApp = new MindApp(".app-2", history);
        if (!history) {
            const root = new MindNode("0", 0);
            root.moveTo({ x: 400, y: 300 });
            root.setContent("新主题");
            mindApp.addNode(root);
        }
        mindApp.enableMouse();
        mindApp.enableKeyDown((ev) => {
            if (ev.key === "Tab") {
                ev.preventDefault();
                if (mindApp.selectNodes && mindApp.selectNodes.length === 1) {
                    mindApp.clearInput();
                    const currentNode = mindApp.selectNodes[0];
                    const newNode = new MindNode(
                        new Date().getTime(),
                        currentNode.level + 1,
                    );
                    newNode.content = "";
                    mindApp.addNode(newNode);
                    currentNode.connectTo(newNode);
                    mindApp.selectNodes = [newNode];
                    mindApp.render();
                }
            } else if (ev.key === "Enter") {
                ev.preventDefault();
                if (mindApp.startInputing) {
                    mindApp.clearInput();
                    mindApp.render();
                } else if (
                    mindApp.selectNodes &&
                    mindApp.selectNodes.length === 1
                ) {
                    const currentNode = mindApp.selectNodes[0];
                    if (currentNode.level >= 1) {
                        const parentLevelNodes = mindApp.vnodes
                            .filter(
                                (node) => node.level === currentNode.level - 1,
                            )
                            .filter((node) =>
                                node.connectToNodes.includes(currentNode),
                            );
                        if (parentLevelNodes && parentLevelNodes.length == 1) {
                            const newNode = new MindNode(
                                new Date().getTime(),
                                currentNode.level,
                            );
                            mindApp.addNode(newNode);
                            parentLevelNodes[0].connectTo(newNode);
                            mindApp.selectNodes = [newNode];
                        }
                    }
                    mindApp.render();
                }
            } else {
                if (
                    !mindApp.startInputing &&
                    mindApp.selectNodes &&
                    mindApp.selectNodes.length === 1
                ) {
                    if (ev.key === "Backspace") {
                        rDelte(mindApp.selectNodes[0]);
                    } else {
                        mindApp.startInput(mindApp.selectNodes[0]);
                    }
                    mindApp.render();
                }
            }
            mindApp.render();
        });
        mindApp.enableSelection();
        mindApp.enableConnection();
        mindApp.enableEdit();
        mindApp.render();

        /**
         * 递归删除节点
         * @param {VNode} node
         * @param {VNode[]} nodeList
         */
        function rDelte(node) {
            mindApp.removeNode(node);
            if (node.parentNodes.length > 0) {
                node.parentNodes.forEach((pNode) => {
                    if (mindApp.vnodes.includes(pNode)) {
                        pNode.connectToNodes.splice(
                            pNode.connectToNodes.indexOf(node),
                            1,
                        );
                    }
                });
            }
            if (node.connectToNodes.length > 0) {
                node.connectToNodes.forEach((subNode) => {
                    rDelte(subNode);
                });
            }
        }
    });

    function saveData() {
        console.log("sava data");
        window.localStorage.setItem("mind-data", mindApp.getData());
    }
</script>

<main>
    <div class="app"></div>
    <div class="app-2"></div>
    <button on:click={saveData}>Save</button>
</main>

<style>
    .app {
        width: 100%;
        height: 1000px;
        background-color: #ccc;
        margin-bottom: 16px;
    }
    .app-2 {
        width: 100%;
        height: 1000px;
        background-color: #eee;
    }

    main {
        text-align: center;
        padding: 1em;
        max-width: 240px;
        margin: 0 auto;
    }

    h1 {
        color: #ff3e00;
        text-transform: uppercase;
        font-size: 4em;
        font-weight: 100;
    }

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
</style>
