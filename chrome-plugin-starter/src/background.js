"use strict";

let timerStarted = false;
chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
  if (request.action === "startTimer") {
    const timeRemaining = request.time;
    startCountdown(timeRemaining);
  } else if (request.action == "checkStatus") {
    if (!timerStarted) {
      chrome.runtime.sendMessage({
        action: "finishedCountdown",
      });
    } else {
      chrome.alarms.get("tomatoesAlarm", function (alarm) {
        if (alarm) {
          // 获取当前时间（毫秒）
          var currentTime = Date.now();
          // 计算剩余时间（毫秒）
          var remainingTime = alarm.scheduledTime - currentTime;
          var seconds = Math.floor(remainingTime / 1000);
          chrome.runtime.sendMessage({
            action: "timerInfo",
            timeRemaining: seconds,
          });
        }
      });
    }
  }
});

chrome.alarms.onAlarm.addListener(function (alarm) {
  if (alarm.name === "tomatoesAlarm") {
    timerStarted = false;
    createNotification();
  }
});

function startCountdown(timeRemaining) {
  chrome.alarms.create("tomatoesAlarm", {
    when: Date.now() + Number(timeRemaining) * 1000,
  });
  timerStarted = true;
}

function createNotification() {
  chrome.notifications.create(
    "countdownNotification",
    {
      type: "basic",
      title: "🍅番茄钟",
      message: `恭喜🎉您完成一次番茄钟.`,
      iconUrl: "icons/icon_48.png",
      priority: 2,
    },
    (notificationId) => {
      console.log("Notification created:", notificationId);
    },
  );
}
