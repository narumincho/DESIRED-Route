/*global Elm*/
const app = Elm.DesiredRoute.fullscreen();
app.ports.elmLoaded.subscribe((text) => {
    "use strict";
    console.log("Elm 読み込み完了");
    // 方向定数
    const Direction =
        Object.freeze({
            right: 0,
            rightDown: 1,
            down: 2,
            leftDown: 3,
            left: 4,
            leftUp: 5,
            up: 6,
            rightUp: 7
        });

    const UpDownNone =
        Object.freeze({
            up: Symbol("up"),
            down: Symbol("down"),
            none: Symbol("ud-none")
        });

    const LeftRightNone =
        Object.freeze({
            left: Symbol("left"),
            right: Symbol("right"),
            none: Symbol("lr-none")
        });
    // 入力状態を保持するグローバル変数
    let keyPressed =
        Object.seal(
            {
                w: false,
                a: false,
                s: false,
                d: false,
                arrowUp: false,
                arrowLeft: false,
                arrowDown: false,
                arrowRight: false
            });
    let lastUd = UpDownNone.none;
    let lastLr = LeftRightNone.none;
    let beforeGamepadButton =
        Object.seal({
            a: false,
            b: false,
            x: false,
            y: false,
            up: false,
            down: false,
            left: false,
            right: false
        });
    let gamepadAxes =
        Object.seal({
            x: 0,
            y: 0
        });
    // 次のフレームの動作を決める変数
    let nextFrameEmit = false;

    // 入力にはこだわる。現在押されているものを第一。2つとも押されてたら最後に押し始めた方を優先
    const getUd = (up, down) => {
        if (up && !down) {
            return UpDownNone.up;
        } else if (!up && down) {
            return UpDownNone.down;
        } else if (up && down) {
            return lastUd;
        }
        return UpDownNone.none;
    };

    const getLr = (left, right) => {
        if (left && !right) {
            return LeftRightNone.left;
        } else if (!left && right) {
            return LeftRightNone.right;
        } else if (left && right) {
            return lastLr;
        }
        return LeftRightNone.none;
    };

    // 動く方向を最終的に決める関数
    const keyToDirection = () => {
        const { up, down, left, right } = beforeGamepadButton;
        const gamepadDir = udLrToDirection(getUd(up, down), getLr(left, right));
        if (gamepadDir !== null) {
            return gamepadDir;
        }
        const stickDir = axesToDirection(gamepadAxes);
        if (stickDir !== null) {
            return stickDir;
        }
        const { w, a, s, d } = keyPressed;
        const wasdDir = udLrToDirection(getUd(w, s), getLr(a, d));
        if (wasdDir !== null) {
            return wasdDir;
        }
        const { arrowUp, arrowDown, arrowLeft, arrowRight } = keyPressed;
        return udLrToDirection(getUd(arrowUp, arrowDown), getLr(arrowLeft, arrowRight));
    };

    const axesToDirection = ({ x, y }) => {
        if (x * x + y * y < 0.5) {
            return null;
        }
        const rad = Math.atan2(y, x);
        if (rad < -Math.PI * 3 / 4) {
            return Direction.left;
        }
        if (rad < -Math.PI * 1 / 4) {
            return Direction.up;
        }
        if (rad < Math.PI * 1 / 4) {
            return Direction.right;
        }
        return Direction.down;
    };

    const udLrToDirection = (ud, lr) => {
        // 上
        if (ud === UpDownNone.up) {
            return Direction.up;
        }
        // 中
        if (ud === UpDownNone.none) {
            if (lr === LeftRightNone.left) {
                return Direction.left;
            } else if (lr === LeftRightNone.right) {
                return Direction.right;
            }
            return null;
        }
        // 下
        return Direction.down;
    };

    // キーボードを入力した瞬間+リピート
    window.addEventListener("keydown", (e) => {
        if (e.key === " ") {
            nextFrameEmit = true;
        } else if (e.key === "w") {
            keyPressed.w = true;
            lastUd = UpDownNone.up;
        } else if (e.key === "s") {
            keyPressed.s = true;
            lastUd = UpDownNone.down;
        } else if (e.key === "a") {
            keyPressed.a = true;
            lastLr = LeftRightNone.left;
        } else if (e.key === "d") {
            keyPressed.d = true;
            lastLr = LeftRightNone.right;
        } else if (e.key === "ArrowUp") {
            keyPressed.arrowUp = true;
            lastUd = UpDownNone.up;
        } else if (e.key === "ArrowDown") {
            keyPressed.arrowDown = true;
            lastUd = UpDownNone.down;
        } else if (e.key === "ArrowLeft") {
            keyPressed.arrowLeft = true;
            lastLr = LeftRightNone.left;
        } else if (e.key === "ArrowRight") {
            keyPressed.arrowRight = true;
            lastLr = LeftRightNone.right;
        }
    });

    // キーボードを離した瞬間
    window.addEventListener("keyup", (e) => {
        if (e.key === "w") {
            keyPressed.w = false;
        } else if (e.key === "s") {
            keyPressed.s = false;
        } else if (e.key === "a") {
            keyPressed.a = false;
        } else if (e.key === "d") {
            keyPressed.d = false;
        } else if (e.key === "ArrowUp") {
            keyPressed.arrowUp = false;
        } else if (e.key === "ArrowDown") {
            keyPressed.arrowDown = false;
        } else if (e.key === "ArrowLeft") {
            keyPressed.arrowLeft = false;
        } else if (e.key === "ArrowRight") {
            keyPressed.arrowRight = false;
        }
    });

    // ゲームパッドの入力更新
    const gamepadUpdate = () => {
        for (let gp of navigator.getGamepads()) {
            if (gp === null || gp.mapping !== "standard") {
                continue;
            }
            gamepadAxes.x = gp.axes[0];
            gamepadAxes.y = gp.axes[1];
            const buttons = gp.buttons;
            beforeGamepadButton.up = buttons[12].pressed;
            beforeGamepadButton.down = buttons[13].pressed;
            beforeGamepadButton.left = buttons[14].pressed;
            beforeGamepadButton.right = buttons[15].pressed;
            return;
        }
    };

    // Elmに送信!
    const mainLoop = () => {
        gamepadUpdate();
        app.ports.receive.send( keyToDirection() );
        requestAnimationFrame(mainLoop);
    };
    requestAnimationFrame(mainLoop);
});
