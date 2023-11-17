function getFetchOptions() {
    return {
        method: 'GET', headers: {
            host: 'm.iyhdmm.com',
            responseType: 'plain',
            contentType: 'text/html; charset=utf-8',
            userAgent: 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36 Edg/119.0.0.0',
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
    return `https://m.iyhdmm.com${path || ''}${queryParams}`
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
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
    let resp = await request(getUri(), getFetchOptions())
    if (!resp.ok) throw new Error('时间表获取失败，请重试')
    let tempList = []
    const selector = 'body > div.tlist > ul'
    let uls = await resp.doc.querySelectorAll(selector)
    for (const i in uls) {
        const ul = uls[i]
        let temp = []
        let lis = await ul.querySelectorAll('li')
        for (const j in lis) {
            const li = lis[j]
            const status = await li.querySelector('a:nth-child(1)', 'text')
            temp.push({
                name: await li.querySelector('a:nth-child(3)', 'text'),
                url: getUri(await li.querySelector('a:nth-child(3)', 'href')),
                status: status.replaceAll('new', '').trim(),
                isUpdate: status.includes('new'),
            });
        }
        tempList.push(temp)
    }
    return {
        monday: tempList[0],
        tuesday: tempList[1],
        wednesday: tempList[2],
        thursday: tempList[3],
        friday: tempList[4],
        saturday: tempList[5],
        sunday: tempList[6],
    }
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
    return [{
        "name": "地区", "key": "region", "maxSelected": 1, "items": [{
            "name": "日本", "value": "日本"
        }, {
            "name": "中国", "value": "中国"
        }, {
            "name": "欧美", "value": "欧美"
        }]
    }, {
        "name": "版本", "key": "genre", "maxSelected": 1, "items": [{
            "name": "TV", "value": "TV"
        }, {
            "name": "剧场版", "value": "剧场版"
        }, {
            "name": "OVA", "value": "OVA"
        }]
    }, {
        "name": "首字母", "key": "letter", "maxSelected": 1, "items": [{
            "name": "A", "value": "A"
        }, {
            "name": "B", "value": "B"
        }, {
            "name": "C", "value": "C"
        }, {
            "name": "D", "value": "D"
        }, {
            "name": "E", "value": "E"
        }, {
            "name": "F", "value": "F"
        }, {
            "name": "G", "value": "G"
        }, {
            "name": "H", "value": "H"
        }, {
            "name": "I", "value": "I"
        }, {
            "name": "J", "value": "J"
        }, {
            "name": "K", "value": "K"
        }, {
            "name": "L", "value": "L"
        }, {
            "name": "M", "value": "M"
        }, {
            "name": "N", "value": "N"
        }, {
            "name": "O", "value": "O"
        }, {
            "name": "P", "value": "P"
        }, {
            "name": "Q", "value": "Q"
        }, {
            "name": "R", "value": "R"
        }, {
            "name": "S", "value": "S"
        }, {
            "name": "T", "value": "T"
        }, {
            "name": "U", "value": "U"
        }, {
            "name": "V", "value": "V"
        }, {
            "name": "W", "value": "W"
        }, {
            "name": "X", "value": "X"
        }, {
            "name": "Y", "value": "Y"
        }, {
            "name": "Z", "value": "Z"
        }]
    }, {
        "name": "年份", "key": "year", "maxSelected": 1, "items": [{
            "name": "2023", "value": "2023"
        }, {
            "name": "2022", "value": "2022"
        }, {
            "name": "2021", "value": "2021"
        }, {
            "name": "2020", "value": "2020"
        }, {
            "name": "2019", "value": "2019"
        }, {
            "name": "2018", "value": "2018"
        }, {
            "name": "2017", "value": "2017"
        }, {
            "name": "2016", "value": "2016"
        }, {
            "name": "2015", "value": "2015"
        }, {
            "name": "2014", "value": "2014"
        }, {
            "name": "2013", "value": "2013"
        }, {
            "name": "2012", "value": "2012"
        }, {
            "name": "2011", "value": "2011"
        }, {
            "name": "2010", "value": "2010"
        }, {
            "name": "2009", "value": "2009"
        }, {
            "name": "2008", "value": "2008"
        }, {
            "name": "2007", "value": "2007"
        }, {
            "name": "2006", "value": "2006"
        }, {
            "name": "2005", "value": "2005"
        }, {
            "name": "2004", "value": "2004"
        }, {
            "name": "2003", "value": "2003"
        }, {
            "name": "2002", "value": "2002"
        }, {
            "name": "2001", "value": "2001"
        }, {
            "name": "2000以前", "value": "2000以前"
        }]
    }, {
        "name": "季度", "key": "season", "maxSelected": 1, "items": [{
            "name": "1月", "value": "1月"
        }, {
            "name": "4月", "value": "4月"
        }, {
            "name": "7月", "value": "7月"
        }, {
            "name": "10月", "value": "10月"
        }]
    }, {
        "name": "状态", "key": "status", "maxSelected": 1, "items": [{
            "name": "连载", "value": "连载"
        }, {
            "name": "完结", "value": "完结"
        }, {
            "name": "未播放", "value": "未播放"
        }]
    }, {
        "name": "类型", "key": "label", "maxSelected": 1, "items": [{
            "name": "搞笑", "value": "搞笑"
        }, {
            "name": "运动", "value": "运动"
        }, {
            "name": "励志", "value": "励志"
        }, {
            "name": "热血", "value": "热血"
        }, {
            "name": "战斗", "value": "战斗"
        }, {
            "name": "竞技", "value": "竞技"
        }, {
            "name": "校园", "value": "校园"
        }, {
            "name": "青春", "value": "青春"
        }, {
            "name": "爱情", "value": "爱情"
        }, {
            "name": "冒险", "value": "冒险"
        }, {
            "name": "后宫", "value": "后宫"
        }, {
            "name": "百合", "value": "百合"
        }, {
            "name": "治愈", "value": "治愈"
        }, {
            "name": "萝莉", "value": "萝莉"
        }, {
            "name": "魔法", "value": "魔法"
        }, {
            "name": "悬疑", "value": "悬疑"
        }, {
            "name": "推理", "value": "推理"
        }, {
            "name": "奇幻", "value": "奇幻"
        }, {
            "name": "科幻", "value": "科幻"
        }, {
            "name": "游戏", "value": "游戏"
        }, {
            "name": "神魔", "value": "神魔"
        }, {
            "name": "恐怖", "value": "恐怖"
        }, {
            "name": "血腥", "value": "血腥"
        }, {
            "name": "机战", "value": "机战"
        }, {
            "name": "战争", "value": "战争"
        }, {
            "name": "犯罪", "value": "犯罪"
        }, {
            "name": "历史", "value": "历史"
        }, {
            "name": "社会", "value": "社会"
        }, {
            "name": "职场", "value": "职场"
        }, {
            "name": "剧情", "value": "剧情"
        }, {
            "name": "伪娘", "value": "伪娘"
        }, {
            "name": "耽美", "value": "耽美"
        }, {
            "name": "童年", "value": "童年"
        }, {
            "name": "教育", "value": "教育"
        }, {
            "name": "亲子", "value": "亲子"
        }, {
            "name": "真人", "value": "真人"
        }, {
            "name": "歌舞", "value": "歌舞"
        }, {
            "name": "肉番", "value": "肉番"
        }, {
            "name": "美少女", "value": "美少女"
        }, {
            "name": "轻小说", "value": "轻小说"
        }, {
            "name": "吸血鬼", "value": "吸血鬼"
        }, {
            "name": "女性向", "value": "女性向"
        }, {
            "name": "泡面番", "value": "泡面番"
        }, {
            "name": "欢乐向", "value": "欢乐向"
        }]
    }, {
        "name": "排序", "key": "order", "maxSelected": 1, "items": [{
            "name": "更新时间", "value": "更新时间"
        }, {
            "name": "名称", "value": "名称"
        }, {
            "name": "点击量", "value": "点击量"
        }]
    }]
}

/**
 * 搜索番剧列表
 * @param {number} pageIndex 当前页码(默认值1)
 * @param {number} pageSize 当前页数据量(默认值25)
 * @param {string} keyword 搜索关键字
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
async function searchAnimeList(pageIndex, pageSize, keyword, filterSelect) {
    let resp = await request(getUri('/s_all', {
        'pageindex': pageIndex, 'pagesize': pageSize, 'kw': keyword, ...filterSelect
    }), getFetchOptions())
    if (!resp.ok) {
        if (resp.code === 404) return []
        throw new Error('番剧搜索失败，请重试')
    }
    return parserAnimeList(resp.doc)
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
    let resp = await request(getUri('/list/', {
        'pageindex': pageIndex - 1, 'pagesize': pageSize, ...filterSelect
    }), getFetchOptions())
    if (!resp.ok) {
        if (resp.code === 404) return []
        throw new Error('番剧搜索失败，请重试')
    }
    return parserAnimeList(resp.doc)
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
    let resp = await request(animeUrl, getFetchOptions())
    if (!resp.ok) throw new Error('获取番剧详情失败，请重试')
    let info = await resp.doc.querySelector('body > div.list > div.show')
    let cover = await info.querySelector('img', 'src')
    if (cover?.startsWith('//')) cover = `https:${cover}`
    let resIndex = 10000;
    let resources = []
    let resList = await resp.doc.querySelectorAll('body > div.tabs > div.main0 > div.movurl')
    for (const i in resList) {
        let index = 0
        let temp = []
        let items = await resList[i].querySelectorAll('ul > li > a')
        for (const j in items) {
            let item = items[j]
            temp.push({
                name: await item.querySelector('a', 'text'),
                url: getUri(await item.querySelector('a', 'href')),
                order: parseInt(`${resIndex}${index++}`),
            })
        }
        if (temp.length > 0) resources.push(temp)
    }
    let name = await info.querySelector('h1', 'text')
    let pInfoList = await info.querySelectorAll('div.info-sub > p', 'text')
    let updateTime = pInfoList[3].replaceAll(/\n|上映：/g, '').trim()
    let region = ''
    let types = pInfoList[4].replaceAll(/类型：/g, '').trim()
        .split(/\n/)
    let last = types.pop()
    if (last) types.push(last)
    let status = pInfoList[2].replaceAll(/\n|连载：/g, '').trim()
    let intro = await resp.doc.querySelector('body > div.info', 'text')
    return {
        url: animeUrl,
        name: name,
        cover: cover,
        updateTime: updateTime,
        region: region,
        types: types,
        status: status,
        intro: intro,
        resources: resources,
    }
}

function unicode(str) {
    let value = '';
    for (let i = 0; i < str.length; i++) {
        let code = parseInt(str.charCodeAt(i))
        value += '\\u' + left_zero_4(code.toString(16)).toUpperCase();
    }
    return value;
}

function left_zero_4(str) {
    if (str != null && str !== '' && str !== 'undefined') {
        if (str.length === 2) return '00' + str;
    }
    return str;
}

function isChineseCharacter(char) {
    const regExp = /^[\u4e00-\u9fa5]$/;
    return regExp.test(char);
}

function genQike123(url, name) {
    let qike123 = ''
    for (let i = 0; i < name.length; i++) {
        const char = name.charAt(i);
        if (isChineseCharacter(char)) {
            qike123 += unicode(char);
        } else {
            qike123 += char;
        }
    }
    qike123 = qike123.replaceAll('\\', '%')
        .replaceAll('!', '%21')
        .replaceAll(' ', '%20')
    return encodeURIComponent(`qike123=${qike123}^${url}_$_|`)
}

function genCookie(cookies, url, name) {
    let t1 = cookies[0].split('=')[1]
    let t2 = parseInt(t1) - Math.floor(Math.random() * 3000)
    let k2 = (t1 / 1000) >> 5;
    k2 = (k2 * (k2 % 256 + 1) + 35236) * (k2 % 128 + 1) * (k2 % 16 + 1) + k2;
    let m2t = parseInt(`${new Date().getTime() / 1000}`) >> 19;
    m2t = (m2t * 21 + 154) * (m2t % 64 + 13) * (m2t % 32 + 34) * (m2t % 16 + 87) * (m2t % 8 + 65) + 751;
    let k1t1 = cookies.join(';')
    let qike123 = genQike123(url, name)
    return `m2t=${m2t};${k1t1};${qike123};k2=${k2};t2=${t2}`
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
    if (resourceUrls.length <= 0) return []
    let headers = {
        'Host': 'm.iyhdmm.com',
        'Accept-Encoding': 'gzip, deflate, br',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.67',
    }
    let tempList = []
    for (const i in resourceUrls) {
        try {
            const url = resourceUrls[i]
            let resp = await request(url, {method: 'GET', headers: headers})
            if (!resp.ok) throw new Error('获取播放地址失败，请重试')
            let name = (await resp.doc
                .querySelector('meta[name="description"]', 'content'))
                .replaceAll(' - 免费在线观看&下载 - 樱花动漫', '')
            let cookies = resp.headers['set-cookie']
            cookies = cookies.replaceAll('; Path=/', '').split(';')
            headers['Cookie'] = genCookie(cookies, url, name)
            let keys = url.split('/').pop().replaceAll('.html', '').split('-')
            resp = await request(getUri('/playurl', {
                aid: keys[0], playindex: keys[1], epindex: keys[2], r: Math.random()
            }), {
                method: 'GET', headers: {'Referer': url, ...headers}
            })
            if (!resp.ok) continue
            if (resp.text.startsWith('ipchk') || resp.text.endsWith('404.mp4')) continue
            tempList.push({
                url: url, playUrl: decodeURIComponent(playUrl('', url, 0, resp.text))
            })
            await sleep(800)
        } catch (e) {
            throw e
        }
    }
    return tempList
}

/**
 * 饭局相关推荐列表
 * @param {string} animeUrl 番剧详情页地址
 * @param {Map.<string,string>} animeInfo 番剧详情信息
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
async function loadRecommendList(animeUrl, animeInfo) {
    let resp = await request(getUri('/list/', {
        'region': animeInfo.region, 'label': animeInfo.types[0]
    }), getFetchOptions())
    if (!resp.ok) {
        if (resp.code === 404) return []
        throw new Error('番剧搜索失败，请重试')
    }
    return parserAnimeList(resp.doc)
}


async function parserAnimeList(doc) {
    let tempList = []
    const selector = 'body > div.list > ul > li'
    let lis = await doc.querySelectorAll(selector)
    for (const i in lis) {
        const li = lis[i]
        let cover = await li.querySelector('div > a > div > div', 'style')
        cover = cover.match(/'([^']+)'/)[0].replaceAll('\'', '')
        if (cover?.startsWith('//')) cover = `https:${cover}`
        let status = (await li.querySelector('a', 'text')).replace(/\s/g, '')
        let name = await li.querySelector('a.itemtext', 'text')
        let url = getUri(await li.querySelector('div > a', 'href'))
        let types = []
        let intro = ''
        tempList.push({
            cover: cover, status: status, name: name, types: types, intro: intro, url: url,
        })
    }
    return tempList
}

/**
 * 以下代码不用了解含义，主要用于解析视频播放地址
 * @type {{}}
 */
function playUrl(id, _0x5c7162, _0x6bcb0c, _0x5f0ee5) {
    if (_0x5f0ee5.indexOf('not\x20verified') >= 0) {
        if (_0x6bcb0c < 3) {
            return playUrl(id, _0x5c7162, _0x6bcb0c + 1);
        } else {
            return ![];
        }
    }
    var _0xc6b4e6 = JSON.parse(function (_0x1d70f8) {
        if (_0x1d70f8.indexOf('{') < 0) {
            var _0x1020e5 = '';
            const _0x5af0f3 = 1561;
            const length = _0x1d70f8.length;
            for (var i = 0; i < length; i += 2) {
                var _0x2b5229 = parseInt(_0x1d70f8[i] + _0x1d70f8[i + 1], 16);
                _0x2b5229 = (_0x2b5229 + 256000 - _0x5af0f3 - (length / 2 - 1 - i / 2)) % 256;
                _0x1020e5 = String.fromCharCode(_0x2b5229) + _0x1020e5;
            }
            _0x1d70f8 = _0x1020e5;
        }
        return _0x1d70f8;
    }(_0x5f0ee5));
    return _0xc6b4e6['vurl']
}