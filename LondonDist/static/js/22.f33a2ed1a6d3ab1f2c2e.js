webpackJsonp([22],{"+WnG":function(t,e){},"5mWc":function(t,e,i){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var a=i("Dd8w"),s=i.n(a),n=i("cNyQ"),o=i("0xDb"),c=i("1h8J"),l=i("NYxO"),r={data:function(){return{borderColor:!1,nameStr:"",toastFalg:!1,fullHeight:null,listData:null}},components:{headTop:n.a},computed:s()({},Object(l.c)(["getDevicelist","getDevicesdata","roomName"]),{deviceList:function(){return this.getDevicelist},devicesData:function(){return this.getDevicesdata},RoomName:function(){return this.roomName}}),created:function(){this.data_init()},mounted:function(){Object(c.d)(this.NAVIGATOR,this),this.fullHeight=document.documentElement.clientHeight,console.log(this.listData)},methods:s()({},Object(l.b)(["setRoomdata","setDevicelist"]),{data_init:function(){this.listData=this.deviceList,this.listData.forEach(function(t){t.status=!1})},tabswitch:function(t){console.log(t.status);var e=t.status;this.$delete(t,"status"),this.$set(t,"status",!e)},Finished:function(){var t=this,e="",i=[],a=JSON.parse(Object(o.b)("roomData")),s=!0;console.log(e,"添加设备的mac");var n=void 0;if(a.forEach(function(e){e.name===t.RoomName&&(i=e.icon)}),this.listData.length>0&&(e=this.listData.map(function(t){if(t.status)return s=!1,i.push(t.mode),t.mac}).filter(function(t){return void 0!==t})),s)return this.$router.go(-1),!1;a.forEach(function(i){i.name===t.RoomName&&(i.mac=i.mac?i.mac+"&"+e.join("&"):e.join("&"),n=i.mac)}),console.log(n,"房间mac"),Object(o.e)("roomData",a),this.setRoomdata(a);var c=this.deviceList;c.length&&(c=c.filter(function(t){if(n.indexOf(t.mac)<0)return t})),this.setDevicelist(c),this.$router.go(-1)}})},u={render:function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{attrs:{id:"addRoom"}},[a("head-top",{attrs:{title:"Add Devices",goBack:"true"}}),t._v(" "),a("div",{staticClass:"content"},[a("div",{staticClass:"list"},[a("span",[t._v("Select the device you want to add")]),t._v(" "),a("ul",{directives:[{name:"show",rawName:"v-show",value:t.listData.length>0,expression:"listData.length > 0"}]},t._l(t.listData,function(e){return a("li",{key:e.id},[a("div",{staticClass:"left"},[a("img",{attrs:{src:e.icon,alt:""}}),t._v(" "),a("span",[t._v(t._s(e.name))])]),t._v(" "),a("div",{staticClass:"right",on:{click:function(i){t.tabswitch(e)}}},[e.status?a("img",{attrs:{src:i("2MzF"),alt:""}}):t._e(),t._v(" "),e.status?t._e():a("img",{attrs:{src:i("pPZp"),alt:""}})])])})),t._v(" "),0===t.listData.length?a("div",{staticClass:"noList"},[t._v("\n        No devices\n      ")]):t._e()]),t._v(" "),a("div",{staticClass:"nextbtn",on:{click:t.Finished}},[a("span",[t._v("Finished")])])])],1)},staticRenderFns:[]};var d=i("VU/8")(r,u,!1,function(t){i("+WnG")},"data-v-cac4cfd6",null);e.default=d.exports}});
//# sourceMappingURL=22.f33a2ed1a6d3ab1f2c2e.js.map