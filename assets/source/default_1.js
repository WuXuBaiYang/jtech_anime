function getFetchOptions() {
    return {
        method: 'GET', headers: {
            host: 'hanime1.me',
            responseType: 'plain',
            contentType: 'text/html; charset=utf-8',
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.67',
        }
    }
}

function getUri(path, params) {
    let queryParams = '';
    let obj = (params || {})
    Object.keys(obj).forEach((key) => {
        let item = `${key}=${obj[key]}`
        if (queryParams.length === 0) {
            queryParams += `?${item}`;
        } else {
            queryParams += `&${item}`
        }
    });
    return `https://hanime1.me${path || ''}${queryParams}`
}

/**
 * 获取番剧时间表
 * @returns {Map} {
 *         'monday': ['周一番剧列表'],
 *         'tuesday': ['周二番剧列表'],
 *         'wednesday': ['周三番剧列表'],
 *         'thursday': ['周四番剧列表'],
 *         'friday': ['周五番剧列表'],
 *         'saturday': ['周六番剧列表'],
 *         'sunday': ['周日番剧列表'],
 *     }
 */
async function getTimeTable() {
    return {}
}

/**
 * 获取首页番剧列表的过滤条件(推荐写死到本配置内)
 * @returns {Array} [
 *     {
 *         'name': '过滤项名称',
 *         'key': '过滤项字段',
 *         'maxSelected': 最大可选数量(int),
 *         'items': [
 *              {
 *                  'name':'过滤项子项名称',
 *                  'value':'过滤项子项值'
 *              }
 *         ]
 *     }
 * ]
 */
async function loadFilterList() {
    return [
        {
            "name": "类型",
            "key": "genre",
            "maxSelected": 1,
            "items": [
                {"name": "全部", "value": "全部"},
                {"name": "裏番", "value": "裏番"},
                {"name": "泡麵番", "value": "泡麵番"},
                {"name": "Motion Anime", "value": "Motion Anime"},
                {"name": "3D動畫", "value": "3D動畫"},
                {"name": "同人作品", "value": "同人作品"},
                {"name": "Cosplay", "value": "Cosplay"},
            ]
        },
        {
            "name": "影片屬性",
            "key": "tags[]",
            "maxSelected": 1,
            "items": [{"name": "無碼", "value": "無碼"}, {"name": "AI解碼", "value": "AI解碼"}, {
                "name": "中文字幕",
                "value": "中文字幕"
            }, {"name": "1080p", "value": "1080p"}, {"name": "60FPS", "value": "60FPS"}]
        },
        {
            "name": "人物關係",
            "key": "tags[]",
            "maxSelected": 1,
            "items": [{"name": "近親", "value": "近親"}, {"name": "姐", "value": "姐"}, {
                "name": "妹",
                "value": "妹"
            }, {"name": "母", "value": "母"}, {"name": "女兒", "value": "女兒"}, {
                "name": "師生",
                "value": "師生"
            }, {"name": "情侶", "value": "情侶"}, {"name": "青梅竹馬", "value": "青梅竹馬"}]
        },
        {
            "name": "角色設定",
            "key": "tags[]",
            "maxSelected": 1,
            "items": [{"name": "JK", "value": "JK"}, {"name": "處女", "value": "處女"}, {
                "name": "御姐",
                "value": "御姐"
            }, {"name": "熟女", "value": "熟女"}, {"name": "人妻", "value": "人妻"}, {
                "name": "老師",
                "value": "老師"
            }, {"name": "女醫護士", "value": "女醫護士"}, {"name": "OL", "value": "OL"}, {
                "name": "大小姐",
                "value": "大小姐"
            }, {"name": "偶像", "value": "偶像"}, {"name": "女僕", "value": "女僕"}, {
                "name": "巫女",
                "value": "巫女"
            }, {"name": "修女", "value": "修女"}, {"name": "風俗娘", "value": "風俗娘"}, {
                "name": "公主",
                "value": "公主"
            }, {"name": "女戰士", "value": "女戰士"}, {"name": "魔法少女", "value": "魔法少女"}, {
                "name": "異種族",
                "value": "異種族"
            }, {"name": "妖精", "value": "妖精"}, {"name": "魔物娘", "value": "魔物娘"}, {
                "name": "獸娘",
                "value": "獸娘"
            }, {"name": "碧池", "value": "碧池"}, {"name": "痴女", "value": "痴女"}, {
                "name": "不良少女",
                "value": "不良少女"
            }, {"name": "傲嬌", "value": "傲嬌"}, {"name": "病嬌", "value": "病嬌"}, {
                "name": "無口",
                "value": "無口"
            }, {"name": "偽娘", "value": "偽娘"}, {"name": "扶他", "value": "扶他"}]
        },
        {
            "name": "外貌身材",
            "key": "tags[]",
            "maxSelected": 1,
            "items": [{"name": "短髮", "value": "短髮"}, {"name": "馬尾", "value": "馬尾"}, {
                "name": "雙馬尾",
                "value": "雙馬尾"
            }, {"name": "巨乳", "value": "巨乳"}, {"name": "貧乳", "value": "貧乳"}, {
                "name": "黑皮膚",
                "value": "黑皮膚"
            }, {"name": "眼鏡娘", "value": "眼鏡娘"}, {"name": "獸耳", "value": "獸耳"}, {
                "name": "美人痣",
                "value": "美人痣"
            }, {"name": "肌肉女", "value": "肌肉女"}, {"name": "白虎", "value": "白虎"}, {
                "name": "大屌",
                "value": "大屌"
            }, {"name": "水手服", "value": "水手服"}, {"name": "體操服", "value": "體操服"}, {
                "name": "泳裝",
                "value": "泳裝"
            }, {"name": "比基尼", "value": "比基尼"}, {"name": "和服", "value": "和服"}, {
                "name": "兔女郎",
                "value": "兔女郎"
            }, {"name": "圍裙", "value": "圍裙"}, {"name": "啦啦隊", "value": "啦啦隊"}, {
                "name": "旗袍",
                "value": "旗袍"
            }, {"name": "絲襪", "value": "絲襪"}, {"name": "吊襪帶", "value": "吊襪帶"}, {
                "name": "熱褲",
                "value": "熱褲"
            }, {"name": "迷你裙", "value": "迷你裙"}, {"name": "性感內衣", "value": "性感內衣"}, {
                "name": "丁字褲",
                "value": "丁字褲"
            }, {"name": "高跟鞋", "value": "高跟鞋"}, {"name": "淫紋", "value": "淫紋"}]
        },
        {
            "name": "故事劇情",
            "key": "tags[]",
            "maxSelected": 1,
            "items": [{"name": "純愛", "value": "純愛"}, {"name": "戀愛喜劇", "value": "戀愛喜劇"}, {
                "name": "後宮",
                "value": "後宮"
            }, {"name": "開大車", "value": "開大車"}, {"name": "公眾場合", "value": "公眾場合"}, {
                "name": "NTR",
                "value": "NTR"
            }, {"name": "精神控制", "value": "精神控制"}, {"name": "藥物", "value": "藥物"}, {
                "name": "痴漢",
                "value": "痴漢"
            }, {"name": "阿嘿顏", "value": "阿嘿顏"}, {"name": "精神崩潰", "value": "精神崩潰"}, {
                "name": "獵奇",
                "value": "獵奇"
            }, {"name": "BDSM", "value": "BDSM"}, {"name": "綑綁", "value": "綑綁"}, {
                "name": "眼罩",
                "value": "眼罩"
            }, {"name": "項圈", "value": "項圈"}, {"name": "調教", "value": "調教"}, {
                "name": "異物插入",
                "value": "異物插入"
            }, {"name": "肉便器", "value": "肉便器"}, {"name": "胃凸", "value": "胃凸"}, {
                "name": "強制",
                "value": "強制"
            }, {"name": "逆強制", "value": "逆強制"}, {"name": "女王樣", "value": "女王樣"}, {
                "name": "母女丼",
                "value": "母女丼"
            }, {"name": "姐妹丼", "value": "姐妹丼"}, {"name": "凌辱", "value": "凌辱"}, {
                "name": "出軌",
                "value": "出軌"
            }, {"name": "攝影", "value": "攝影"}, {"name": "性轉換", "value": "性轉換"}, {
                "name": "百合",
                "value": "百合"
            }, {"name": "耽美", "value": "耽美"}, {"name": "異世界", "value": "異世界"}, {
                "name": "怪獸",
                "value": "怪獸"
            }, {"name": "世界末日", "value": "世界末日"}]
        },
        {
            "name": "性交體位",
            "key": "tags[]",
            "maxSelected": 1,
            "items": [{"name": "手交", "value": "手交"}, {"name": "指交", "value": "指交"}, {
                "name": "乳交",
                "value": "乳交"
            }, {"name": "肛交", "value": "肛交"}, {"name": "腳交", "value": "腳交"}, {
                "name": "拳交",
                "value": "拳交"
            }, {"name": "3P", "value": "3P"}, {"name": "群交", "value": "群交"}, {
                "name": "口交",
                "value": "口交"
            }, {"name": "口爆", "value": "口爆"}, {"name": "吞精", "value": "吞精"}, {
                "name": "舔蛋蛋",
                "value": "舔蛋蛋"
            }, {"name": "舔穴", "value": "舔穴"}, {"name": "69", "value": "69"}, {
                "name": "自慰",
                "value": "自慰"
            }, {"name": "腋毛", "value": "腋毛"}, {"name": "腋交", "value": "腋交"}, {
                "name": "舔腋下",
                "value": "舔腋下"
            }, {"name": "內射", "value": "內射"}, {"name": "顏射", "value": "顏射"}, {
                "name": "雙洞齊下",
                "value": "雙洞齊下"
            }, {"name": "懷孕", "value": "懷孕"}, {"name": "噴奶", "value": "噴奶"}, {
                "name": "放尿",
                "value": "放尿"
            }, {"name": "排便", "value": "排便"}, {"name": "顏面騎乘", "value": "顏面騎乘"}, {
                "name": "車震",
                "value": "車震"
            }, {"name": "性玩具", "value": "性玩具"}, {"name": "毒龍鑽", "value": "毒龍鑽"}, {
                "name": "觸手",
                "value": "觸手"
            }, {"name": "頸手枷", "value": "頸手枷"}]
        },
        {
            "name": "排序方式",
            "key": "sort",
            "maxSelected": 1,
            "items": [
                {"name": "最新上市", "value": "最新上市"},
                {"name": "最新上傳", "value": "最新上傳"},
                {"name": "本日排行", "value": "本日排行"},
                {"name": "本週排行", "value": "本週排行"},
                {"name": "本月排行", "value": "本月排行"},
                {"name": "觀看次數", "value": "觀看次數"},
                {"name": "他們在看", "value": "他們在看"},
            ]
        },
        {
            "name": "發佈年份",
            "key": "year",
            "maxSelected": 1,
            "items": [
                {"name": "2023年", "value": "2023"},
                {"name": "2022年", "value": "2022"},
                {"name": "2021年", "value": "2021"},
                {"name": "2020年", "value": "2020"},
                {"name": "2019年", "value": "2019"},
                {"name": "2018年", "value": "2018"},
                {"name": "2017年", "value": "2017"},
                {"name": "2016年", "value": "2016"},
                {"name": "2015年", "value": "2015"},
                {"name": "2014年", "value": "2014"},
                {"name": "2013年", "value": "2013"},
                {"name": "2012年", "value": "2012"},
                {"name": "2011年", "value": "2011"},
                {"name": "2010年", "value": "2010"},
                {"name": "2009年", "value": "2009"},
                {"name": "2008年", "value": "2008"},
                {"name": "2007年", "value": "2007"},
                {"name": "2006年", "value": "2006"},
                {"name": "2005年", "value": "2005"},
                {"name": "2004年", "value": "2004"},
                {"name": "2003年", "value": "2003"},
                {"name": "2002年", "value": "2002"},
                {"name": "2001年", "value": "2001"},
                {"name": "2000年", "value": "2000"},
                {"name": "1999年", "value": "1999"},
                {"name": "1998年", "value": "1998"},
                {"name": "1997年", "value": "1997"},
                {"name": "1996年", "value": "1996"},
                {"name": "1995年", "value": "1995"},
                {"name": "1994年", "value": "1994"},
                {"name": "1993年", "value": "1993"},
                {"name": "1992年", "value": "1992"},
                {"name": "1991年", "value": "1991"},
                {"name": "1990年", "value": "1990"}
            ],
        },
        {
            "name": "發佈月份",
            "key": "month",
            "maxSelected": 1,
            "items": [
                {"month": "1月", "value": "1"},
                {"month": "2月", "value": "2"},
                {"month": "3月", "value": "3"},
                {"month": "4月", "value": "4"},
                {"month": "5月", "value": "5"},
                {"month": "6月", "value": "6"},
                {"month": "7月", "value": "7"},
                {"month": "8月", "value": "8"},
                {"month": "9月", "value": "9"},
                {"month": "10月", "value": "10"},
                {"month": "11月", "value": "11"},
                {"month": "12月", "value": "12"}
            ],
        },
    ]
}

/**
 * 搜索番剧列表
 * @param {number} pageIndex 当前页码(默认值1)
 * @param {number} pageSize 当前页数据量(默认值25)
 * @param {string} keyword 搜索关键字
 * @returns {Array} [
 *         {
 *             'name': '过滤项名称',
 *             'key': '过滤项字段',
 *             'maxSelected': 最大可选数量(int),
 *             'items': [
 *                 {
 *                     'name': '过滤项子项名称',
 *                     'value': '过滤项子项值'
 *                 }
 *             ]
 *         }
 *     ]
 */
async function searchAnimeList(pageIndex, pageSize, keyword) {
    return []
}

/**
 * **必填方法**
 * 获取首页番剧列表
 * @param {number} pageIndex 当前页码(默认值1)
 * @param {number} pageSize 当前页数据量(默认值25)
 * @param {Map.<string,string>} filterSelect 用户选择的过滤条件(key：过滤项 value：过滤值)
 * @returns {Array} [
 *         {
 *             'name': '番剧名称',
 *             'cover': '番剧封面',
 *             'status': '当前状态（更新到xx集/已完结等）',
 *             'types': '番剧类型（武侠/玄幻这种）',
 *             'intro': '番剧介绍',
 *             'url': '番剧详情页地址'
 *         }
 *     ]
 */
async function loadHomeList(pageIndex, pageSize, filterSelect) {
    return []
}

/**
 * **必填方法**
 * 获取番剧详情信息
 * @param {string} animeUrl 番剧详情页地址
 * @returns {Map} {
 *         'url': '番剧详情页地址',
 *         'name': '番剧名称',
 *         'cover': '番剧封面',
 *         'updateTime': '更新时间（不需要格式化）',
 *         'region': '地区',
 *         'types': '番剧类型（武侠/玄幻这种）',
 *         'status': '当前状态（更新到xx集/已完结等）',
 *         'intro': '番剧介绍',
 *         'resources': [
 *             [
 *                 {
 *                     'name': '资源名称',
 *                     'url': 'url资源地址（可以是目标页面的地址或者播放地址，在使用的时候会通过getPlayUrls结构进行转换）',
 *                     'order': 排序方式（int,推荐结构10001、10002，如果有多个资源使用前部结构区分）,
 *                 }
 *             ]
 *         ],
 *     }
 */
async function getAnimeDetail(animeUrl) {
    return {}
}

/**
 * **必填方法**
 * 根据资源地址转换为可播放/下载地址
 * 如果资源地址本身就是播放地址，也会调用此接口，直接返回即可
 * @param {Array.<string>} resourceUrls 资源地址列表(value：资源地址)
 * @returns {Map} [
 *         {
 *             'url': '资源地址（转换前）',
 *             'playUrl': '播放/下载地址（转换后）'
 *         }
 *     ]
 */
async function getPlayUrls(resourceUrls) {
    return []
}