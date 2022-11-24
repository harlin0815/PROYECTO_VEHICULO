var app = new Vue({
    el: '#app',
    data: {
        message: 'hola',
        info:[]
    },
    mounted() {
        
     axios.get("https://api.dailymotion.com/videos?channel=sport&limit=10").then(respuesta=>this.info=respuesta.data.list)
    },
});