import SwiftUI

/**
 # 分区最新视频
 
 - [获取分区最新视频列表](#获取分区最新视频列表)
 
 ---
 {
 "code": 0,
 "message": "0",
 "ttl": 1,
 "data": {
 "page": {
 "num": 1,
 "size": 2,
 "count": 189
 },
 "archives": [{
 "aid": 56998612,
 "videos": 24,
 "tid": 21,
 "tname": "日常",
 "copyright": 1,
 "pic": "http://i2.hdslb.com/bfs/archive/76536be425ed98ba1f1b9aef1ada3a09f94c9f04.jpg",
 "title": "操控百万UP主的一天！",
 "pubdate": 1562568733,
 "ctime": 1561624175,
 "desc": "拍这个视频还挺辛苦的，希望大家喜欢的话给个三连叭！",
 "state": 0,
 "attribute": 536887424,
 "duration": 1864,
 "rights": {
 "bp": 0,
 "elec": 0,
 "download": 0,
 "movie": 0,
 "pay": 0,
 "hd5": 0,
 "no_reprint": 1,
 "autoplay": 0,
 "ugc_pay": 0,
 "is_cooperation": 0,
 "ugc_pay_preview": 0,
 "no_background": 0
 },
 "owner": {
 "mid": 2206456,
 "name": "花少北丶",
 "face": "http://i1.hdslb.com/bfs/face/86ef6895a8f88c80f2885e7eb9ba7989db437b93.jpg"
 },
 "stat": {
 "aid": 56998612,
 "view": 2863604,
 "danmaku": 82588,
 "reply": 5502,
 "favorite": 65471,
 "coin": 104905,
 "share": 5815,
 "now_rank": 0,
 "his_rank": 12,
 "like": 165638,
 "dislike": 0
 },
 "dynamic": "你想看的这里都有！",
 "cid": 99548502,
 "dimension": {
 "width": 1920,
 "height": 1080,
 "rotate": 0
 },
 "bvid": "BV1Wx411d7jX"
 }, {
 "aid": 837503204,
 "videos": 1,
 "tid": 21,
 "tname": "日常",
 "copyright": 1,
 "pic": "http://i1.hdslb.com/bfs/archive/7025827d8dbfc6139a2d066daa51a08897282534.jpg",
 "title": "“都是小人物，就别说什么大话了，活着就行”",
 "pubdate": 1585264054,
 "ctime": 1585264054,
 "desc": "每一位用心生活的小人物，都是各自生活中不平凡的英雄！",
 "state": 0,
 "attribute": 16512,
 "duration": 295,
 "mission_id": 12868,
 "rights": {
 "bp": 0,
 "elec": 0,
 "download": 0,
 "movie": 0,
 "pay": 0,
 "hd5": 0,
 "no_reprint": 1,
 "autoplay": 1,
 "ugc_pay": 0,
 "is_cooperation": 0,
 "ugc_pay_preview": 0,
 "no_background": 0
 },
 "owner": {
 "mid": 350928606,
 "name": "彼岸的岛",
 "face": "http://i2.hdslb.com/bfs/face/9814b8b6defc045aa07c3bb08e8a30e63afd9f3e.jpg"
 },
 "stat": {
 "aid": 837503204,
 "view": 142239,
 "danmaku": 602,
 "reply": 702,
 "favorite": 4728,
 "coin": 4712,
 "share": 917,
 "now_rank": 0,
 "his_rank": 0,
 "like": 7700,
 "dislike": 0
 },
 "dynamic": "#全能打卡挑战##正能量##感人#",
 "cid": 169901162,
 "dimension": {
 "width": 1280,
 "height": 720,
 "rotate": 0
 },
 "bvid": "BV1cg4y1a7tB"
 }]
 }
 }
 ```
 */
struct VideoDynamicArchiveDTO:Decodable {
    let aid:Int
    let tid:Int
    let tname:String
    let pic:String
    let title:String
    let desc:String
    let owner:OwnerDTO
    let bvid:String
    let cid:Int
}
