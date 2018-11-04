<script src="http://35.233.44.60:8290/divolte.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/mustache.js/3.0.0/mustache.min.js"></script>
<script src="https://code.jquery.com/jquery-3.3.1.js"></script>
<script src="https://requirejs.org/docs/release/2.3.6/minified/require.js"></script>
<script>
    requirejs.config({
      paths: {
        divolte: 'http://35.233.44.60:8290/divolte'
      }
    });
 
    require(['divolte']);
    require(['divolte'], function(divolte) {
        console.log('ok1');
        checkout_click = function() {
            console.log('ok2');
            var id_product = this.id.split('_buy_link')[0];
            var id_price_product = id_product.concat('_price');
            var id_price_total_product = id_product.concat('_price_total');
            var price_product = document.getElementById(id_price_product).innerHTML.trim();

            try {
                var price_total_product = document.getElementById(id_price_total_product).innerHTML.trim().split('<strong>')[1].split('</strong>')[0];
            } catch(err) {
                price_total_product = price_product
            }
            divolte.signal("checkout", {id: id_product, price: price_product, total_price: price_total_product});
            return false;
        };
        $(document.body).on('click', '.btn-primary', checkout_click);
    });
</script>
