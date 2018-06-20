class GeoLocation
{
    protected coord: Coordinates;

    constructor(pos: Position) {
        this.coord = pos.coords;
    }

    lat() { return this.coord.latitude; }
    lng() { return this.coord.longitude; }
}

class GeoLocationUtil
{
    static onLocationMoved(f: (l: GeoLocation)=>void): void {
        if (!navigator.geolocation) return;

        var lastTime = 0;

        // 現在の位置情報取得を実施
        navigator.geolocation.watchPosition(
            // 位置情報取得成功時
            function (pos) {
                var now = new Date();
                var l = new GeoLocation(pos);
                console.log("current location=[" + l.lat() + ", " + l.lng() + "] " + now.toString());

                var epoc = now.getTime();
                // 最後に位置を取得してから一定秒以上経過するまでは無視する
                if (lastTime == 0 || lastTime + 5000 < epoc) {
                    f(l);
                    lastTime = epoc;
                }
            },
            // 位置情報取得失敗時
            function (err) {
                console.log("### ERROR: Can't get current location. err.code=" + err.code);
            },
            // オプション
            {
                maximumAge: 0,            // キャッシュ有効期限(ミリ秒)
                timeout: 20000,           // タイムアウト(ミリ秒)
                enableHighAccuracy: true  // 高精度
            });
    }
}
