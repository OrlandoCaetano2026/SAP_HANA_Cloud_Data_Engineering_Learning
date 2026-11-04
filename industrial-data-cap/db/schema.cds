namespace industrial.data;

entity PurchaseOrder {
  key EBELN : String(10);
      LIFNR : String(10);
      PO_DATE : Date;
      CURRENCY : String(5);
}

entity Material {
  key MATNR : String(40);
      MATNR_TEXT : String(100);
      MTART : String(4);
      CREATED_DATE : Date;
}
