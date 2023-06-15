
CALL make_v(0, 'Document', @v_id_doc);
CALL make_c(@v_id_doc, @c_id_doc);

CALL make_v(0, 'Document01', @v_id_doc1);
CALL make_o(@v_id_doc1, @o_id_doc1);

CALL make_v(0, 'title', @v_id_title);
CALL make_a(@v_id_title, @a_id_title);

CALL make_co(@c_id_doc, @o_id_doc1, @co_id_doc_doc1);

CALL make_v(0, '', @v_id_empty_str);
CALL make_ac(@c_id_doc, @a_id_title, @v_id_empty_str, @ac_id_doc_title);

CALL make_v(0, 'Doc Title 01', @v_id_title_01);
CALL make_aco(@co_id_doc_doc1, @ac_id_doc_title, @v_id_title_01, @aco_id_doc_title_01);
