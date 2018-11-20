mapping {
   map sessionId() onto 'sessionId'
   map timestamp() onto 'timestamp'
   map referer() onto 'referer'
   map remoteHost() onto 'remoteHost'
   map eventType() onto 'eventType'
   map location() onto 'location'
   map userAgentString() onto 'userAgent'
   def ua = userAgent()
   map ua.deviceCategory() onto 'userAgentDeviceCategory'
   map ua.deviceCategory() onto 'userAgentDeviceCategory'
   map ua.osFamily() onto 'userAgentOsFamily'
   map ua.osVersion() onto 'userAgentOsVersion'
   map eventParameter('basket_price') onto 'basket_price'
   map eventParameter('item_id')      onto 'item_id'
   map eventParameter('item_price')   onto 'item_price'
   map eventParameter('item_url')     onto 'item_url'
   //map eventParameters().value('id') onto 'id_product'
   //map eventParameters().value('price') onto 'price_product'
   //map eventParameters().value('total_price') onto 'total_price_product'
   def locationUri = parse location() to uri
   def localUri = parse locationUri.rawFragment() to uri
   map localUri.path() onto 'localPath'
}

// Long version - need avro.avsc mapping
mapping {
    map duplicate() onto 'detectedDuplicate'
    map corrupt() onto 'detectedCorruption'
    map firstInSession() onto 'firstInSession'
    map timestamp() onto 'timestamp'
    map remoteHost() onto 'remoteHost'
    map referer() onto 'referer'
    map location() onto 'location'
    map viewportPixelWidth() onto 'viewportPixelWidth'
    map viewportPixelHeight() onto 'viewportPixelHeight'
    map screenPixelWidth() onto 'screenPixelWidth'
    map screenPixelHeight() onto 'screenPixelHeight'
    map partyId() onto 'partyId'
    map sessionId() onto 'sessionId'
    map pageViewId() onto 'pageViewId'
    map eventType() onto 'eventType'

    map userAgentString() onto 'userAgentString'
    def ua = userAgent()
    map ua.name() onto 'userAgentName'
    map ua.family() onto 'userAgentFamily'
    map ua.vendor() onto 'userAgentVendor'
    map ua.type() onto 'userAgentType'
    map ua.version() onto 'userAgentVersion'
    map ua.deviceCategory() onto 'userAgentDeviceCategory'
    map ua.osFamily() onto 'userAgentOsFamily'
    map ua.osVersion() onto 'userAgentOsVersion'
    map ua.osVendor() onto 'userAgentOsVendor'

    map eventParameter('basket_price') onto 'basket_price'
    map eventParameter('item_id')      onto 'item_id'
    map eventParameter('item_price')   onto 'item_price'
    map eventParameter('item_url')     onto 'item_url'
}