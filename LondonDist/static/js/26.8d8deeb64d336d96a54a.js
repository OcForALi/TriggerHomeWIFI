webpackJsonp([26],{"9Vr3":function(e,t){},ltX2:function(e,t,s){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var a=s("Dd8w"),i=s.n(a),n=s("cNyQ"),o=s("QLTB"),c=s("NYxO"),r=s("71C0"),l=["Hearter","HeatMat","Humidifier","Light12/12","Light15/8","AirPump","Irrigationpump"],u={data:function(){return{borderColor:!1,value:this.$route.params.name,toastFalg:!1,clickOut:!0,pickData:[l],unit:[""],wheels:null,selectedIndex:[2],fullHeight:null,selectedValue:[]}},components:{headTop:n.a,picker:o.a},computed:i()({},Object(c.c)(["getcurrentMac"]),{currentDeviceMAC:function(){return this.getcurrentMac}}),mounted:function(){this.fullHeight=document.documentElement.clientHeight;var e=this.$refs.picker;this.selectedValue=e.getInitValue(),e.show(),this.value=this.selectedValue,console.log(this.selectedValue)},methods:{next:function(){this.clickOut&&!this.toastFalg&&(console.log(this.value.toString()),Object(r.C)(this.NAVIGATOR,this,this.currentDeviceMAC,this.value.toString()),this.$store.state.user.deviceName=this.value.toString(),console.log(this.$store.state.user.deviceName),this.$root.ISDEBUG&&window.reNameResponse(this.currentDeviceMAC,!0),this.$router.push({path:"/Me/adsuccess"}))},nameExp:function(e){/^\w{0,}$/.test(e)?(this.toastFalg=!1,this.clickOut=!0):(this.toastFalg=!0,this.clickOut=!1)},change:function(e){this.selectedValue=e}},watch:{selectedValue:function(e){this.value=e,console.log(this.selectedValue)}}},d={render:function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("div",{style:{height:e.fullHeight+"px"},attrs:{id:"deviceName"}},[s("head-top",{attrs:{title:"Device Rename",goBack:"true"}}),e._v(" "),s("div",{staticClass:"content"},[s("span",[e._v("Please name your device")]),e._v(" "),s("div",{staticClass:"editorName",class:e.borderColor?"active_color":""},[s("input",{directives:[{name:"model",rawName:"v-model",value:e.value,expression:"value"}],attrs:{type:"text",placeholder:"e.g.Tom 's plug, Plug in garden ",maxlength:"16"},domProps:{value:e.value},on:{focus:function(t){e.borderColor=!e.borderColor},blur:function(t){e.borderColor=!e.borderColor},input:[function(t){t.target.composing||(e.value=t.target.value)},function(t){e.nameExp(e.value)}]}})]),e._v(" "),s("span",{style:{color:e.toastFalg?"red":""}},[e._v("Tip：1.2-16  characters，only chinese and engish and numbers allowed")]),e._v(" "),s("span",[e._v("2.Location naming is recommended")]),e._v(" "),s("p",[e._v("Choose from list of presets for fast set up. Our Presets come preloaded with standard controls speciﬁc for that device use. These can be amended on the device set up controls in ‘Control Centre’.")]),e._v(" "),s("picker",{ref:"picker",staticClass:"picker",attrs:{data:e.pickData,"selected-index":e.selectedIndex,unit:e.unit},on:{change:e.change}}),e._v(" "),s("div",{staticClass:"nextbtn",class:{nextDisable:!e.clickOut},on:{click:e.next}},[s("span",[e._v("Next")])])],1)],1)},staticRenderFns:[]};var h=s("VU/8")(u,d,!1,function(e){s("9Vr3")},"data-v-56bfabf6",null);t.default=h.exports}});
//# sourceMappingURL=26.8d8deeb64d336d96a54a.js.map