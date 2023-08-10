/**
 * 获取数据源信息
 * @returns {string} '{
 *         'key': '数据源唯一值，当与已有数据源重叠的时候会自动覆盖，可以使用英文名或缩写',
 *         'name': '数据源名称',
 *         'homepage': '数据源首页地址',
 *         'version': '版本号',
 *         'lastEditDate': '最后更新的时间戳，Iso8601格式',
 *         'logoUrl': '数据源图标在线地址',
 *     }'
 */
async function getSourceInfo() {
    return JSON.stringify({
        key: 'yhdmz',
        name: '樱花动漫',
        homepage: 'https://www.yhdmz.org',
        version: '1.0.0',
        lastEditDate: '2023-08-10T17:19:42.113727',
        logoUrl: 'https://www.yhdmz.org/tpsf/yh_pic/favicon.ico',
    });
}

/**
 * 获取番剧时间表
 * @returns {string} '{
 *         'monday': ['周一番剧列表'],
 *         'tuesday': ['周二番剧列表'],
 *         'wednesday': ['周三番剧列表'],
 *         'thursday': ['周四番剧列表'],
 *         'friday': ['周五番剧列表'],
 *         'saturday': ['周六番剧列表'],
 *         'sunday': ['周日番剧列表'],
 *     }'
 */
async function getTimeTable() {
    return JSON.stringify({})
}

/**
 * 获取首页番剧列表的过滤条件(推荐写死到本配置内)
 * @returns {string} '[
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
 * ]'
 */
async function loadFilterList() {
    return JSON.stringify([])
}

/**
 * 获取数据源信息
 * @param {number} pageIndex 当前页码
 * @param {number} pageSize 当前页数据量
 * @param {string} keyword 搜索关键字
 * @returns {string} '[
 // *     {
 // *         'name': '过滤项名称',
 // *         'key': '过滤项字段',
 // *         'maxSelected': 最大可选数量(int),
 // *         'items': [
 // *              {
 // *                  'name':'过滤项子项名称',
 // *                  'value':'过滤项子项值'
 // *              }
 // *         ]
 // *     }
 * ]'
 */
async function searchAnimeList(pageIndex, pageSize, keyword) {

}

async function loadHomeList(pageIndex, pageSize, filterSelect) {

}

async function getAnimeDetail(animeUrl) {

}

async function getPlayUrls(resourceUrls) {

}