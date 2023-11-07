<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
	
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<script src="./js/wnInterface.js"></script> 
<script src="./js/mcore.min.js"></script> 
<script src="./js/mcore.extends.js"></script> 
<link rel="stylesheet" href="./css/freeDetail.css">

<script>

M.plugin("location").current({
    timeout: 10000,
    maximumAge: 1,
    callback: function( result ) {
        if ( result.status === 'NS' ) {
            console.log('This Location Plugin is not supported');
        }
        else if ( result.status !== 'SUCCESS' ) {
            if ( result.message ) {
                console.log( result.status + ":" + result.message );
            }
            else {
                console.log( 'Getting GPS coords is failed' );
            }
        }
        else {
            if ( result.coords ) {
                console.log( JSON.stringify(result.coords) );
            }
            else {
                console.log( 'It cann\'t get GPS Coords.' );
            }
        }
    }
});

</script>

<title>Insert title here</title>

  <style>

.map_wrap, .map_wrap * {margin:0; padding:0;font-family:'Malgun Gothic',dotum,'돋움',sans-serif;font-size:12px;}
.map_wrap {position:relative;width:100%;height:350px;}

.placeinfo_wrap {position:absolute;bottom:28px;left:-150px;width:300px;}
.placeinfo {position:relative;width:100%;border-radius:6px;border: 1px solid #ccc;border-bottom:2px solid #ddd;padding-bottom: 10px;background: #fff;}
.placeinfo:nth-of-type(n) {border:0; box-shadow:0px 1px 2px #888;}
.placeinfo_wrap .after {content:'';position:relative;margin-left:-12px;left:50%;width:22px;height:12px;background:url('https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/vertex_white.png')}
.placeinfo a, .placeinfo a:hover, .placeinfo a:active{color:#fff;text-decoration: none;}
.placeinfo a, .placeinfo span {display: block;text-overflow: ellipsis;overflow: hidden;white-space: nowrap;}
.placeinfo span {margin:5px 5px 0 5px;cursor: default;font-size:13px;}
.placeinfo .title {font-weight: bold; font-size:14px;border-radius: 6px 6px 0 0;margin: -1px -1px 0 -1px;padding:10px; color: #fff;background: #d95050;background: #d95050 url(https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/arrow_white.png) no-repeat right 14px center;}
.placeinfo .tel {color:#0f7833;}
.placeinfo .jibun {color:#999;font-size:11px;margin-top:0;}
 
    .wrap {position: absolute;left: 0;bottom: 40px;width: 288px;height: 132px;margin-left: -144px;text-align: left;overflow: hidden;font-size: 12px;font-family: 'Malgun Gothic', dotum, '돋움', sans-serif;line-height: 1.5;}
    .wrap * {padding: 0;margin: 0;}
    .wrap .info {width: 286px;height: 120px;border-radius: 5px;border-bottom: 2px solid #ccc;border-right: 1px solid #ccc;overflow: hidden;background: #fff;}
    .wrap .info:nth-child(1) {border: 0;box-shadow: 0px 1px 2px #888;}
    .info .title {padding: 5px 0 0 10px;height: 30px;background: #eee;border-bottom: 1px solid #ddd;font-size: 18px;font-weight: bold;}
    .info .close {position: absolute;top: 10px;right: 10px;color: #888;width: 17px;height: 17px;background: url('https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/overlay_close.png');}
    .info .close:hover {cursor: pointer;}
    .info .body {position: relative;overflow: hidden;}
    .info .desc {position: relative;margin: 13px 0 0 90px;height: 75px;}
    .desc .ellipsis {overflow: visible;text-overflow: ellipsis;white-space: normal;}
    .desc .jibun {font-size: 11px;color: #888;margin-top: -2px;}
    .info .img {position: absolute;top: 6px;left: 5px;width: 73px;height: 71px;border: 1px solid #ddd;color: #888;overflow: hidden;}
    .info:after {content: '';position: absolute;margin-left: -12px;left: 50%;bottom: 0;width: 22px;height: 12px;background: url('https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/vertex_white.png')}
    .info .link {color: #5085BB;}
</style>

</head>
<body>

<div class="map_wrap">
    <div id="map" style="width:70%;height:500px;position:relative;overflow:hidden;"></div>
</div>

 
	
	<!--실제 지도를 그리는 javascript API를 불러오기-->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=80e6cca959046a32e36bfd9340bd8485&libraries=services"></script>

	
	
		<script type="text/javascript"
			src="//dapi.kakao.com/v2/maps/sdk.js?appkey=80e6cca959046a32e36bfd9340bd8485"></script>



<script>

//마커를 클릭했을 때 해당 장소의 상세정보를 보여줄 커스텀오버레이입니다
var placeOverlay = new kakao.maps.CustomOverlay({ zIndex: 1 }),
    contentNode = document.createElement('div'), // 커스텀 오버레이의 컨텐츠 엘리먼트 입니다
    markers = [],
    currCategory = ''; // 현재 선택된 카테고리를 가지고 있을 변수입니다

var mapContainer = document.getElementById('map'); // 지도를 표시할 div

var mapOption = {
    center: new kakao.maps.LatLng(37.566826, 126.9786567), // 지도의 중심좌표
    level: 5 // 지도의 확대 레벨
};

// 지도를 생성합니다
var map = new kakao.maps.Map(mapContainer, mapOption);

// 주소-좌표 변환 객체를 생성합니다
var geocoder = new kakao.maps.services.Geocoder();
var hospitals = []; // 병원 데이터를 저장하는 배열

//커스텀 오버레이 변수를 전역 범위에서 정의합니다
var overlay = new kakao.maps.CustomOverlay({
    content: contentNode,
    map: map
});



<c:forEach items="${hospitalList}" var="h">
	var hospitalNumber = "${h.hno}";
    var title = "${h.hname}";
    var address = "${h.haddr}";
    var opentime = "${h.hopentime}";
    var closetime = "${h.hclosetime}";
    var nightday = "${h.hnightday}";
    var nightendtime = "${h.hnightendtime}";
    var himg = "${h.himg}";
    var hbreaktime = "${h.hbreaktime}";
    var hbreakendtime = "${h.hbreakendtime}";


    
    hospitals.push({
    	hospitalNumber: hospitalNumber,
        title: title,
        address: address,
        opentime: opentime,
        closetime: closetime,
        nightday: nightday,
        nightendtime: nightendtime,
        himg: himg,
        hbreaktime: hbreaktime,
        hbreakendtime: hbreakendtime
        
    });
</c:forEach>


function timeToMinutes(time) {
    const parts = time.split(":");
    if (parts.length === 2) {
        const hours = parseInt(parts[0], 10);
        const minutes = parseInt(parts[1], 10);
        return hours * 60 + minutes;
    }
    return 0; // 예외 처리
}

function checkBusinessStatus(opentime, closetime, nightday, nightendtime) {
    const now = new Date();
    const currentDay = now.getDay(); // 0: 일요일, 1: 월요일, ..., 6: 토요일
    const currentTime = now.getHours() * 60 + now.getMinutes(); // 현재 시간을 분 단위로 표시

    const openMinutes = timeToMinutes(opentime);
    const closeMinutes = timeToMinutes(closetime);
    const nightEndMinutes = timeToMinutes(nightendtime);
  
    
    if (nightday == currentDay) {
        if (currentTime >= openMinutes && currentTime <= nightEndMinutes) {
            return "진료중";        
        } else {
            return "진료종료";
        }
    } else {
        if (currentTime >= openMinutes && currentTime <= closeMinutes) {
            return "진료중";
        } else {
            return "진료종료";
        }
    }    
}




hospitals.forEach(function (position) {
    // 주소로 좌표를 검색합니다
    geocoder.addressSearch(position.address, function (result, status) {
        // 정상적으로 검색이 완료됐으면
        if (status === kakao.maps.services.Status.OK) {
            var coords = new kakao.maps.LatLng(result[0].y, result[0].x);

            // 결과값으로 받은 위치를 마커로 표시합니다
            var marker = new kakao.maps.Marker({
                map: map,
                position: coords
            });

            // 마커 클릭 이벤트 리스너를 추가합니다.
            kakao.maps.event.addListener(marker, 'click', function () {
                // 클릭한 마커의 정보를 가져옵니다.
                var hospitalNumber = position.hospitalNumber;
                var title = position.title;
                var address = position.address;
                var opentime = position.opentime;
                var closetime = position.closetime;
                var nightendtime = position.nightendtime;
                var nightday = position.nightday;
                var himg = position.himg;
                var hbreaktime = position.hbreaktime;
                var hbreakendtime = position.hbreakendtime;
                
                const currentDay = new Date().getDay(); // 0: 일요일, 1: 월요일, ..., 6: 토요일
    
                // 영업 상태를 확인합니다.
                var status = checkBusinessStatus(opentime, closetime, nightday, nightendtime);

                // 커스텀 오버레이의 내용을 업데이트합니다.
                var overlayContent = '<div class="wrap">' +
                    '    <div class="info"><a href="http://localhost:hospitalDetail/' + hospitalNumber + '" target="_blank" class="link">' +
                    '        <div class="title">' +
                    '            ' + title +
                    '            <div class="close" onclick="closeOverlay()" title="닫기"></div>' +
                    '        </div>' +
                    '        <div class="body">' +
                    '            <div class="img">' +
                    '                <img src="' + himg + '" width="73" height="70">' +
                    '           </div>' +
                    '            <div class="desc">' +
                    '                <div class="ellipsis">' + address + '</div>' +
                    '                <div class="time">' + opentime + "~" + (nightday == currentDay ? nightendtime : closetime) + '</div>' +
                    '                <div class="status">' + status + '</div>' +
                    '            </div>' +
                    '        </div>' +
                    '    </a></div>' +
                    '</div>';

                // 커스텀 오버레이를 업데이트합니다.
                overlay.setContent(overlayContent);
                overlay.setPosition(marker.getPosition());

                // 커스텀 오버레이를 지도에 표시합니다.
                overlay.setMap(map);
            });
        }
    });
});

//커스텀 오버레이를 닫기 위해 호출되는 함수입니다 
function closeOverlay() {
    overlay.setMap(null);     
}

 
</script>

</body>
</html>