webpackJsonp([25],{DPxO:function(e,t){},NhtP:function(e,t,a){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var s=a("Dd8w"),o=a.n(s),n=a("cNyQ"),r=a("NYxO"),l=a("71C0"),i=a("1h8J"),c={data:function(){return{borderColor:!1,value:"",toastFalg:!1}},components:{"head-vue":n.a},computed:o()({},Object(r.c)(["getuserName"]),{firstName:function(){return this.getuserName}}),created:function(){this.value=this.firstName,Object(i.z)(this.NAVIGATOR,this,"changename")},mounted:function(){},methods:o()({},Object(r.b)(["userName"]),{nameExp:function(e){/^\w{0,}$/.test(e)?this.toastFalg=!1:this.toastFalg=!0},save:function(){""!==this.value&&(this.userName(this.value),Object(l.z)(this.NAVIGATOR,this,"name",this.value),console.log(this.value))},clear:function(){this.value=""}})},u={render:function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("div",{attrs:{id:"changename"}},[s("head-vue",{attrs:{title:"Change Name",goBack:"true"}},[s("div",{attrs:{slot:"setRight"},on:{click:e.save},slot:"setRight"},[e._v("Save")])]),e._v(" "),s("div",{staticClass:"editorName",class:e.borderColor?"active_color":""},[s("input",{directives:[{name:"model",rawName:"v-model",value:e.value,expression:"value"}],attrs:{type:"text",placeholder:"only letters and numbers allowed",maxlength:"16"},domProps:{value:e.value},on:{focus:function(t){e.borderColor=!e.borderColor},blur:function(t){e.borderColor=!e.borderColor},input:[function(t){t.target.composing||(e.value=t.target.value)},function(t){e.nameExp(e.value)}]}}),e._v(" "),s("img",{attrs:{src:a("vW/C"),alt:""},on:{click:e.clear}})]),e._v(" "),s("div",{staticClass:"text"},[e._v("1-16 characters")]),e._v(" "),e.toastFalg?s("div",{staticClass:"toast"},[e._v("\n    only letters and numbers allowed\n  ")]):e._e()],1)},staticRenderFns:[]};var v=a("VU/8")(c,u,!1,function(e){a("DPxO")},"data-v-633e2e67",null);t.default=v.exports}});
//# sourceMappingURL=25.e9cc4321c270da552688.js.map