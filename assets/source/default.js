function getFetchOptions() {
    return {
        method: 'GET',
        host: 'www.yhdmz.org',
        responseType: 'plain',
        contentType: 'text/html; charset=utf-8',
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ' + '(KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.67',
    }
}

function getBaseUrl() {
    return 'https://www.yhdmz.org'
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
    let html = await requestText(getBaseUrl(), getFetchOptions())
    let tempList = []
    const selector = 'body > div.area > div.side.r > div.bg > div.tlist > ul'
    let uls = await html.querySelectorAll(selector)
    for (const i in uls) {
        const ul = uls[i]
        let temp = []
        let lis = await ul.querySelectorAll('li')
        for (const j in lis) {
            const li = lis[j]
            const status = await li.querySelector('a:nth-child(1)', 'text')
            const path = await li.querySelector('a:nth-child(3)', 'href')
            temp.push({
                'name': await li.querySelector('a:nth-child(3)', 'text'),
                'url': getBaseUrl() + path,
                'status': status.replaceAll('new', '').trim(),
                'isUpdate': status.includes('new'),
            });
        }
        tempList.push(temp)
    }
    return {
        'monday': tempList[0],
        'tuesday': tempList[1],
        'wednesday': tempList[2],
        'thursday': tempList[3],
        'friday': tempList[4],
        'saturday': tempList[5],
        'sunday': tempList[6],
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
        'name': '过滤项名称', 'key': '过滤项字段', 'maxSelected': 最大可选数量(int), 'items': [{
            'name': '过滤项子项名称', 'value': '过滤项子项值'
        }]
    }]
}

/**
 * 搜索番剧列表
 * @param {number} pageIndex 当前页码
 * @param {number} pageSize 当前页数据量
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
    return [{
        'name': '过滤项名称', 'key': '过滤项字段', 'maxSelected': 最大可选数量(int), 'items': [{
            'name': '过滤项子项名称', 'value': '过滤项子项值'
        }]
    }]
}

/**
 * **必填方法**
 * 获取首页番剧列表
 * @param {number} pageIndex 当前页码
 * @param {number} pageSize 当前页数据量
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
    return [{
        'name': '番剧名称',
        'cover': '番剧封面',
        'status': '当前状态（更新到xx集/已完结等）',
        'types': '番剧类型（武侠/玄幻这种）',
        'intro': '番剧介绍',
        'url': '番剧详情页地址'
    }]
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
    return {
        'url': '番剧详情页地址',
        'name': '番剧名称',
        'cover': '番剧封面',
        'updateTime': '更新时间（不需要格式化）',
        'region': '地区',
        'types': '番剧类型（武侠/玄幻这种）',
        'status': '当前状态（更新到xx集/已完结等）',
        'intro': '番剧介绍',
        'resources': [[{
            'name': '资源名称',
            'url': 'url资源地址（可以是目标页面的地址或者播放地址，在使用的时候会通过getPlayUrls结构进行转换）',
            'order': 1,
        }]],
    }
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
    return [{
        'url': '资源地址（转换前）', 'playUrl': '播放/下载地址（转换后）'
    }]
}