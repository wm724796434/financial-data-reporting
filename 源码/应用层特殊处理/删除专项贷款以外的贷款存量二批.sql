DELETE FROM PBOCD.JS_201_CLZXEP  
 WHERE CJRQ = $DATA_DATE
    AND FRNBJGH = '990000'
   AND AGRI_FLG <> '1'
   AND POORLOAN_FLG <> '1'
   --AND POORPER_FLG <> '1'
   AND LINCOMEHOUSE_FLG <> '1'
   --AND GREEN_FLG <> '1'
   --AND VENTURE_FLG <> '1'     
	 ;
	 --20250327变更，该三个字段停止报送，加工时候默认置空，影响判断 注掉