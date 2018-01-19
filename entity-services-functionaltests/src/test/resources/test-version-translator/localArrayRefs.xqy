xquery version '1.0-ml';
module namespace localArrayRefTgt-from-localArrayRefSrc
    = 'http://localArrayRefTgt/localArrayRefTgt-0.0.2-from-localArrayRefSrc-0.0.1';

import module namespace es = 'http://marklogic.com/entity-services'
    at '/MarkLogic/entity-services/entity-services.xqy';



declare option xdmp:mapping 'false';

(:
 This module was generated by MarkLogic Entity Services.
 Its purpose is to create instances of entity types
 defined in
 localArrayRefTgt, version 0.0.2
 from documents that were persisted according to model
 localArrayRefSrc, version 0.0.1


 For usage and extension points, see the Entity Services Developer's Guide

 https://docs.marklogic.com/guide/entity-services

 Generated at timestamp: 2017-10-25T11:24:37.117185-07:00

 Target Model localArrayRefTgt-0.0.2 Info:

 Type Order: 
    primaryKey: CustomerID, ( in source: CustomerID )
    required: CustomerID, ( in source: CustomerID )
    range indexes: None, ( in source: CustomerID, OrderDate )
    word lexicons: CustomerID, ( in source: CustomerID, OrderDate )
    namespace: None, ( in source: None )
    namespace prefix: None, ( in source: None )
 
 Type OrderDetail: 
    primaryKey: ProductID, ( in source: ProductID )
    required: ProductID, ( in source: None )
    range indexes: ProductID, Quantity, ( in source: None )
    word lexicons: ProductID, Quantity, ( in source: None )
    namespace: None, ( in source: None )
    namespace prefix: None, ( in source: None )
 
:)


(:~
 : Creates a map:map instance representation of the target
 : entity type Order from an envelope document
 : containing a source entity instance, that is, instance data
 : of type Order, version 0.0.1.
 : @param $source  An Entity Services envelope document (<es:envelope>)
 :  or a canonical XML instance of type Order.
 : @return A map:map instance that holds the data for Order,
 :  version 0.0.2.
 :)

declare function localArrayRefTgt-from-localArrayRefSrc:convert-instance-Order(
    $source as node()
) as map:map
{
    let $source-node := es:init-translation-source($source, 'Order')

    let $CustomerID := $source-node/CustomerID ! xs:string(.)
    let $OrderDate := $source-node/OrderDate ! xs:dateTime(.)
    let $ShipAddress := $source-node/ShipAddress ! xs:string(.)
    let $arr2arr := es:extract-array($source-node/arr2arr, xs:string#1)
    let $extract-reference-OrderDetail := 
        function($path) { 
         if ($path/*)
         then localArrayRefTgt-from-localArrayRefSrc:convert-instance-OrderDetail($path)
         else es:init-instance($path, 'OrderDetail')
         }

    let $OrderDetails := es:extract-array($source-node/OrderDetails/*, $extract-reference-OrderDetail)

    return
        es:init-instance($source, "Order")
       (: Copy attachments from source document to the target :)
        =>es:copy-attachments($source-node)
    (: The following lines are generated from the "Order" entity type. :)
    =>   map:with('CustomerID',   $CustomerID)
    =>es:optional('OrderDate',   $OrderDate)
    =>es:optional('ShipAddress',   $ShipAddress)
    =>es:optional('arr2arr',   $arr2arr)
    =>es:optional('OrderDetails',   $OrderDetails)

};
    
(:~
 : Creates a map:map instance representation of the target
 : entity type OrderDetail from an envelope document
 : containing a source entity instance, that is, instance data
 : of type OrderDetail, version 0.0.1.
 : @param $source  An Entity Services envelope document (<es:envelope>)
 :  or a canonical XML instance of type OrderDetail.
 : @return A map:map instance that holds the data for OrderDetail,
 :  version 0.0.2.
 :)

declare function localArrayRefTgt-from-localArrayRefSrc:convert-instance-OrderDetail(
    $source as node()
) as map:map
{
    let $source-node := es:init-translation-source($source, 'OrderDetail')

    let $ProductID := $source-node/ProductID ! xs:integer(.)
    let $UnitPrice := $source-node/UnitPrice ! xs:integer(.)
    let $Quantity := $source-node/Quantity ! xs:integer(.)

    return
        es:init-instance($source, "OrderDetail")
       (: Copy attachments from source document to the target :)
        =>es:copy-attachments($source-node)
    (: The following lines are generated from the "OrderDetail" entity type. :)
    =>   map:with('ProductID',   $ProductID)
    =>es:optional('UnitPrice',   $UnitPrice)
    =>es:optional('Quantity',   $Quantity)

};
    