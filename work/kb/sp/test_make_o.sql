

CALL  make_v(0, 'Document01', @v_id_doc1);
CALL  make_v(0, 'Sentence01', @v_id_sent1);
CALL  make_v(0, 'Sentence02', @v_id_sent2);

CALL make_o(@v_id_doc1, @o_id_doc1);
CALL make_o(@v_id_sent1, @o_id_sent1);
CALL make_o(@v_id_sent2, @o_id_sent2);

SELECT @o_id_doc1, @o_id_sent1, @o_id_sent2;


