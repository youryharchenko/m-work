package main

/*
func TestSendMail(t *testing.T) {
	pubKey, err := getPubKey("site_public_key.pem")
	if err != nil {
		t.Error("Get pubKey error:", err)
		return
	}

	err = sendMail(pubKey, []string{"youry.in.ua@gmail.com"},
		"To: youry.in.ua@gmail.com\r\nFrom: admin@ptks.net.ua\r\nSubject: Test!\r\n\r\nThis is the email body.\r\n")

	if err != nil {
		t.Error(err)
		return
	}
	t.Error("ok")
}

func TestSendMail2(t *testing.T) {
	pubKey, err := getPubKey("site_public_key.pem")
	if err != nil {
		t.Error("Get pubKey error:", err)
		return
	}

	err = sendMail(pubKey, []string{"george@ukr.net", "youry@ukr.net"},
		"MIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\r\nTo: george@ukr.net,youry@ukr.net\r\nFrom: admin@ptks.net.ua\r\nSubject: Test!\r\n\r\n<p>This is the <b>email body</b>.</p>\r\n")

	if err != nil {
		t.Error(err)
		return
	}
	t.Error("ok")
}

func sendMail(pub *rsa.PublicKey, to []string, msg string) error {

	mail := map[string]interface{}{
		"to":  to,
		"msg": msg,
	}

	buf, err := json.Marshal(mail)
	if err != nil {
		return err
	}

	data := []string{}
	st := 128
	for i := 0; i < len(buf); i += st {
		h := i + st
		if h > len(buf) {
			h = len(buf)
		}
		b := buf[i:h]
		s, err := encode(string(b), pub)
		if err != nil {
			return err
		}
		data = append(data, s)
	}

	req := map[string]interface{}{"data": data}
	rbuf, err := json.Marshal(req)
	if err != nil {
		return err
	}

	r := gorequest.New()
	r.SetDebug(true)

	//fmt.Println(string(rbuf))

	rsp, resp, respErrs := r.Post("https://ptks.net.ua/run.cgi?command=sendmail").SendString(string(rbuf)).End()
	if respErrs != nil {
		return fmt.Errorf("************ Post errors: %v", respErrs)
	}

	if rsp.StatusCode >= 400 {
		return fmt.Errorf("rsp.StatusCode %v", rsp.StatusCode)
	}

	fmt.Println(resp)

	return nil

}
*/
