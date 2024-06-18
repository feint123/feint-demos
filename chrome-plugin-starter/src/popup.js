"use strict";

(function () {
  // 恢复页面数据的值
  chrome.storage.sync.get(["isRunning", "originTimer"], (result) => {
    if (result.originTimer) {
      document.getElementById("timerInput").innerHTML = result.originTimer;
    }
    if (result.isRunning) {
      document.getElementById("startTimer").disabled = true;
    }
  });
  // 定时发送消息检查倒计时的状态
  setInterval(() => {
    chrome.runtime.sendMessage({
      action: "checkStatus",
    });
  }, 1000);

  // 开始按钮的点击事件
  document.getElementById("startTimer").addEventListener("click", function () {
    const timeInMinutes = document.getElementById("timerInput").innerHTML;
    if (timeInMinutes) {
      // 给background 脚本发送消息，开启定时器
      chrome.runtime.sendMessage({
        action: "startTimer",
        time: timeInMinutes * 60,
      });
      // 保存当前设置的时间
      chrome.storage.sync.set(
        {
          originTimer: Number(timeInMinutes),
          isRunning: true,
        },
        () => {},
      );
    }
    document.getElementById("startTimer").disabled = true;
  });

  document.getElementById("timerInput").innerHTML = 25;

  document
    .getElementById("incrementBtn")
    .addEventListener("click", function () {
      updateCounter({
        type: "INCREMENT",
      });
    });

  document
    .getElementById("decrementBtn")
    .addEventListener("click", function () {
      updateCounter({
        type: "DECREMENT",
      });
    });

  function updateCounter({ type }) {
    var count = document.getElementById("timerInput").innerHTML;
    if (type === "INCREMENT") {
      count = Number(count) + 1;
    } else if (type === "DECREMENT") {
      count = Number(count) - 1;
    }
    if (count < 1) {
      count = 1;
    }
    document.getElementById("timerInput").innerHTML = count;
  }

  function resetTimer() {
    // 计时器完成
    // 解除按钮禁用
    document.getElementById("startTimer").disabled = false;
    document.getElementById("countdownText").innerText = "00:00";
    document.querySelector(".circle-progress").style["stroke-dashoffset"] =
      getTimerRingCircle();
    chrome.storage.sync.get(["isRunning"], (result) => {
      // 只有当 isRunning 为 true 时才更新值，防止storage频繁写入
      if (result.isRunning) {
        chrome.storage.sync.set(
          {
            isRunning: false,
          },
          () => {},
        );
      }
    });
  }
  function getTimerRingCircle() {
    return 2 * Math.PI * 20;
  }
  chrome.runtime.onMessage.addListener(
    function (request, sender, sendResponse) {
      if (request.action === "timerInfo") {
        // 计时器运行中更新UI界面展示的进度
        let remainingSeconds = request.timeRemaining;
        const minutes = Math.floor(remainingSeconds / 60);
        const seconds = remainingSeconds % 60;
        document.getElementById("countdownText").innerText =
          `${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
        chrome.storage.sync.get(["originTimer"], (result) => {
          // 更新圆环的填充百分比
          const circleProgress = document.querySelector(".circle-progress");
          const circumference = getTimerRingCircle(); // 半径20的圆的周长
          const offset =
            circumference * (remainingSeconds / (result.originTimer * 60));
          circleProgress.style["stroke-dashoffset"] = offset;
        });
        remainingSeconds = remainingSeconds - 1;
      } else if (request.action == "finishedCountdown") {
        resetTimer();
      }
    },
  );
})();
