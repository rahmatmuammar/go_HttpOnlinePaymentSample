PGDMP     
                    z            DB_OnlinePayment    9.6.20    11.1 *    ?           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            ?           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            ?           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            ?           1262    33890    DB_OnlinePayment    DATABASE     ?   CREATE DATABASE "DB_OnlinePayment" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_Indonesia.1252' LC_CTYPE = 'English_Indonesia.1252';
 "   DROP DATABASE "DB_OnlinePayment";
             postgres    false                        2615    33891    opm    SCHEMA        CREATE SCHEMA opm;
    DROP SCHEMA opm;
             postgres    false            P           1247    34147 (   tp_response_change_account_active_status    TYPE     w   CREATE TYPE opm.tp_response_change_account_active_status AS (
	status_code_int integer,
	desc_var character varying
);
 8   DROP TYPE opm.tp_response_change_account_active_status;
       opm       postgres    false    7            ^           1247    34191    tp_response_debit    TYPE     ?   CREATE TYPE opm.tp_response_debit AS (
	status_code_int integer,
	desc_var character varying,
	balance_before_int integer,
	balance_after_int integer,
	trx_code_txt text
);
 !   DROP TYPE opm.tp_response_debit;
       opm       postgres    false    7            S           1247    34160    tp_response_get_user_info    TYPE     L  CREATE TYPE opm.tp_response_get_user_info AS (
	username_var character varying,
	phone_number_var character varying,
	device_name_var character varying,
	email_var character varying,
	photo_base64_txt text,
	balance_int integer,
	register_on_dtm timestamp without time zone,
	status_active_boo boolean,
	status_login_boo boolean
);
 )   DROP TYPE opm.tp_response_get_user_info;
       opm       postgres    false    7            J           1247    34135    tp_response_login    TYPE     `   CREATE TYPE opm.tp_response_login AS (
	status_code_int integer,
	desc_var character varying
);
 !   DROP TYPE opm.tp_response_login;
       opm       postgres    false    7            M           1247    34141    tp_response_logout    TYPE     a   CREATE TYPE opm.tp_response_logout AS (
	status_code_int integer,
	desc_var character varying
);
 "   DROP TYPE opm.tp_response_logout;
       opm       postgres    false    7            G           1247    34122    tp_response_registration    TYPE     g   CREATE TYPE opm.tp_response_registration AS (
	status_code_int integer,
	desc_var character varying
);
 (   DROP TYPE opm.tp_response_registration;
       opm       postgres    false    7            V           1247    34164    tp_response_topup    TYPE     ?   CREATE TYPE opm.tp_response_topup AS (
	status_code_int integer,
	desc_var character varying,
	balance_before_int integer,
	balance_after_int integer,
	trx_code_txt text
);
 !   DROP TYPE opm.tp_response_topup;
       opm       postgres    false    7            ?            1255    34148 ;   sp_change_account_active_status(character varying, boolean)    FUNCTION     ?  CREATE FUNCTION opm.sp_change_account_active_status(p_phone_number_var character varying, p_active_status boolean) RETURNS opm.tp_response_change_account_active_status
    LANGUAGE plpgsql
    AS $$
	
DECLARE

	v_code_int int4;
	v_message_var varchar;
	
	v_phone_number_count_int int4;
	v_user_status_boo BOOLEAN;
	
	result RECORD;
	
BEGIN
	-- check if phone number isn't registered
	SELECT count(*) into v_phone_number_count_int FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if user already logout
	SELECT status_active_boo INTO v_user_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
		
	--if phone number is not registered
		IF v_phone_number_count_int = 0 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Tidak Terdaftar';
			
	-- if phone number is more than one
		ELSIF v_phone_number_count_int > 1 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Terdaftar Duplikat';

	-- if username has been logged in
		ELSIF v_user_status_boo = p_active_status THEN
			v_code_int := 2;
			v_message_var := 'Akun Sudah Diset';
			
		ELSE
			v_code_int := 0;
			v_message_var := 'Ubah Status Berhasil';
			
			UPDATE opm.user_list SET
				status_active_boo = p_active_status
			WHERE phone_number_var = p_phone_number_var;
		END IF;
		
		SELECT 
			v_code_int,
			v_message_var INTO result;
		RETURN RESULT;
END;

$$;
 r   DROP FUNCTION opm.sp_change_account_active_status(p_phone_number_var character varying, p_active_status boolean);
       opm       postgres    false    592    7            ?            1255    34291 $   sp_debit(character varying, integer)    FUNCTION       CREATE FUNCTION opm.sp_debit(p_phone_number_var character varying, p_value_int integer) RETURNS opm.tp_response_debit
    LANGUAGE plpgsql
    AS $$
	
DECLARE
	
	v_code_int int4;
	v_message_var VARCHAR;
			
	v_phone_number_count_int int4;
	v_user_active_status_boo BOOLEAN;
	v_user_login_status_boo BOOLEAN;
	
	v_trx_type_int int4 := 2;
	v_balance_before_int int4 := 0;
	v_balance_after_int int4 := 0;
	v_buf_trx_code_txt TEXT := '';
	v_trx_code_txt TEXT := '';
	
	result RECORD;
	
BEGIN	
			
	-- check if phone number isn't registered or duplicate
	SELECT count(*) into v_phone_number_count_int FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if user already active
	SELECT status_active_boo INTO v_user_active_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if user already login
	SELECT status_login_boo INTO v_user_login_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if balance is below debit value	
	SELECT balance_int INTO v_balance_before_int from opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- if phone number is not registered
		IF v_phone_number_count_int = 0 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Tidak Terdaftar';
			v_balance_before_int := 0;
			
	-- if phone number is more than one
		ELSIF v_phone_number_count_int > 1 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Terdaftar Duplikat';
			v_balance_before_int := 0;

	-- if username not actived
		ELSIF v_user_active_status_boo is FALSE THEN
			v_code_int := 1;
			v_message_var := 'Akun Tidak Aktif';
			v_balance_before_int := 0;
			
	-- if username not actived
		ELSIF v_user_login_status_boo is FALSE THEN
			v_code_int := 1;
			v_message_var := 'Akun Belum Login';
			v_balance_before_int := 0;
			
	-- if balance is not enough
		ELSIF v_balance_before_int < p_value_int THEN
			v_code_int := 1;
			v_message_var := 'Saldo Tidak Mencukupi';
			v_balance_before_int := 0;
			
		ELSE		
			
				v_code_int := 0;
				v_message_var := 'Berhasil Debit';
				
				-- debit process
				v_balance_after_int := v_balance_before_int - p_value_int;
				
				-- update balance process
				UPDATE opm.user_list SET
					balance_int = v_balance_after_int
				WHERE phone_number_var = p_phone_number_var;			
				
				-- compose to trx code
				SELECT format('%1s%2s%3s%4s%5s%6s', 
					to_char(NOW(), 'YYYYMMDDHH24MISS'),
					lpad(v_trx_type_int::VARCHAR, 2, '0'),
					lpad(v_balance_before_int::VARCHAR, 7, '0'),
					lpad(p_value_int::VARCHAR, 7, '0'),
					lpad(v_balance_after_int::VARCHAR, 7, '0'),
					p_phone_number_var
				) into v_buf_trx_code_txt;
				
				SELECT format('%1s%2s', 
					v_buf_trx_code_txt,
					upper(md5(v_buf_trx_code_txt))
				) into v_trx_code_txt;
				
				-- logging
				INSERT INTO opm.trx_debit
				(
					phone_number_var,
					debit_on_dtm,
					balance_before_int,
					debit_fare_int,
					balance_after_int,
					status_boo,
					desc_status_var,
					debit_transcode_txt
				) 
					VALUES
				(
					p_phone_number_var,				
					TO_TIMESTAMP(to_char(NOW(), 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
					v_balance_before_int,
					p_value_int,
					v_balance_after_int,
					true,
					'ST',
					v_trx_code_txt
				);
			END IF;
		
		SELECT 
			v_code_int,
			v_message_var,
			v_balance_before_int,
			v_balance_after_int,
			v_trx_code_txt
			INTO result;
	
		RETURN RESULT;
END;

$$;
 W   DROP FUNCTION opm.sp_debit(p_phone_number_var character varying, p_value_int integer);
       opm       postgres    false    7    606            ?            1255    34161 #   sp_get_user_info(character varying)    FUNCTION     %  CREATE FUNCTION opm.sp_get_user_info(p_phone_number_var character varying) RETURNS opm.tp_response_get_user_info
    LANGUAGE plpgsql
    AS $$
	
DECLARE
	
	result RECORD;
	
BEGIN	
			
		SELECT 
				usl.user_fullname_var, 
				usl.phone_number_var, 
				usl.device_name_var,
				usl.email_var,
				usl.photo_base64_txt,
				usl.balance_int,
				usl.register_on_dtm,
				usl.status_active_boo,
				usl.status_login_boo FROM opm.user_list usl WHERE phone_number_var = p_phone_number_var INTO result;
	
		RETURN RESULT;
END;

$$;
 J   DROP FUNCTION opm.sp_get_user_info(p_phone_number_var character varying);
       opm       postgres    false    595    7            ?            1255    34224 .   sp_login(character varying, character varying)    FUNCTION     ?  CREATE FUNCTION opm.sp_login(p_phone_number_var character varying, p_password_var character varying) RETURNS opm.tp_response_login
    LANGUAGE plpgsql
    AS $$
	
DECLARE

	v_code_int int4;
	v_message_var varchar;
	
	v_phone_number_count_int int4;	
	v_password_correct_boo BOOLEAN;
	v_user_login_boo BOOLEAN;
	v_user_status_boo BOOLEAN;
	
	result RECORD;
	
BEGIN
	-- check if phone number isn't registered
	SELECT count(*) into v_phone_number_count_int FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if password isn't correct
	SELECT 1 INTO v_password_correct_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var AND password_var = p_password_var;
	
	-- check if account is already logged in
	SELECT status_login_boo INTO v_user_login_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var AND password_var = p_password_var;	
	
	-- check if account is active
	SELECT status_active_boo INTO v_user_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var AND password_var = p_password_var;
		
	--if phone number is not registered
		IF v_phone_number_count_int = 0 THEN
			v_code_int := 1;
			v_message_var := 'Username Tidak Terdaftar';
			
	-- if phone number is more than one
		ELSIF v_phone_number_count_int > 1 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Terdaftar Duplikat';
	
	-- if password was incorrect
		ELSIF v_password_correct_boo is NULL or v_password_correct_boo IS FALSE THEN
			v_code_int := 1;
			v_message_var := 'Password Salah';

	-- if username has been inactive
		ELSIF v_user_status_boo is NULL or v_user_status_boo IS FALSE THEN
			v_code_int := 1;
			v_message_var := 'Akun Tidak Aktif';
			
	-- if username has been logged in
		ELSIF v_user_login_boo is NULL or v_user_login_boo IS TRUE THEN
			v_code_int := 1;
			v_message_var := 'Akun Sudah Login';
			
		ELSE
			v_code_int := 0;
			v_message_var := 'Login Berhasil';
			
			UPDATE opm.user_list SET
				status_login_boo = TRUE,
				desc_status_var = 'LG'
			WHERE phone_number_var = p_phone_number_var;
		END IF;
		
		SELECT 
			v_code_int,
			v_message_var INTO result;
		RETURN RESULT;
END;

$$;
 d   DROP FUNCTION opm.sp_login(p_phone_number_var character varying, p_password_var character varying);
       opm       postgres    false    586    7            ?            1255    34144    sp_logout(character varying)    FUNCTION     W  CREATE FUNCTION opm.sp_logout(p_phone_number_var character varying) RETURNS opm.tp_response_logout
    LANGUAGE plpgsql
    AS $$
	
DECLARE

	v_code_int int4;
	v_message_var varchar;
	
	v_phone_number_count_int int4;
	v_user_status_boo BOOLEAN;
	
	result RECORD;
	
BEGIN
	-- check if phone number isn't registered
	SELECT count(*) into v_phone_number_count_int FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if user already logout
	SELECT status_login_boo INTO v_user_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
		
	--if phone number is not registered
		IF v_phone_number_count_int = 0 THEN
			v_code_int := 1;
			v_message_var := 'Username Tidak Terdaftar';
			
	-- if phone number is more than one
		ELSIF v_phone_number_count_int > 1 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Terdaftar Duplikat';

	-- if username has been logged in
		ELSIF v_user_status_boo IS FALSE THEN
			v_code_int := 2;
			v_message_var := 'Akun Sudah Logout';
			
		ELSE
			v_code_int := 0;
			v_message_var := 'Logout Berhasil';
			
			UPDATE opm.user_list SET
				status_login_boo = FALSE,
				desc_status_var = 'LO'
			WHERE phone_number_var = p_phone_number_var;
		END IF;
		
		SELECT 
			v_code_int,
			v_message_var INTO result;
		RETURN RESULT;
END;

$$;
 C   DROP FUNCTION opm.sp_logout(p_phone_number_var character varying);
       opm       postgres    false    589    7            ?            1255    34123 ?   sp_registration(character varying, character varying, character varying, character varying, text, real, real, character varying)    FUNCTION     [  CREATE FUNCTION opm.sp_registration(p_username_var character varying, p_phone_number_var character varying, p_device_name_var character varying, p_email_var character varying, p_photo_txt text, p_latitude_flo real, p_longitude_flo real, p_password_var character varying) RETURNS opm.tp_response_registration
    LANGUAGE plpgsql
    AS $$

	
DECLARE

	v_code_int int4;
	v_message_var varchar;
	
	v_username_count_int int4;
	v_phone_number_count_int int4;
	
	v_current_date_on_dtm TIMESTAMP;
	
	result RECORD;

BEGIN

	-- check username count
	SELECT count(*) into v_username_count_int FROM opm.user_list WHERE user_fullname_var = p_username_var;

	-- check username count
	SELECT count(*) into v_phone_number_count_int FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if username has been exist
	IF v_username_count_int > 0 THEN
		v_code_int := 1;
		v_message_var := 'Username Telah Terdaftar';
		
	-- check if phone number has been exist
	ELSIF v_phone_number_count_int > 0 THEN
		v_code_int := 1;
		v_message_var := 'Nomor Telepon Telah Terdaftar';
		
	ELSE
		v_code_int := 0;
		v_message_var := 'Registrasi Berhasil';
		
		INSERT INTO opm.user_list
		(
			user_fullname_var,
			phone_number_var,
			password_var,
			device_name_var,
			email_var,
			photo_base64_txt,
			balance_int,
			register_on_dtm,
			status_active_boo,
			status_login_boo,
			desc_status_var,
			latitude_flo,
			longitude_flo
		) 
			VALUES 
		(
			p_username_var, 
			p_phone_number_var, 
			p_password_var,
			p_device_name_var, 
			p_email_var, 
			p_photo_txt, 
			0,
			TO_TIMESTAMP(to_char(NOW(), 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
			TRUE,
			FALSE,
			'NL',
			p_latitude_flo, 
			p_longitude_flo
		);
	END IF;
	
	SELECT 
		v_code_int,
		v_message_var INTO result; 	
	RETURN result;
	
END;
$$;
   DROP FUNCTION opm.sp_registration(p_username_var character varying, p_phone_number_var character varying, p_device_name_var character varying, p_email_var character varying, p_photo_txt text, p_latitude_flo real, p_longitude_flo real, p_password_var character varying);
       opm       postgres    false    7    583            ?            1255    34240 $   sp_topup(character varying, integer)    FUNCTION     u  CREATE FUNCTION opm.sp_topup(p_phone_number_var character varying, p_value_int integer) RETURNS opm.tp_response_topup
    LANGUAGE plpgsql
    AS $$
	
DECLARE
	
	v_code_int int4;
	v_message_var VARCHAR;
			
	v_phone_number_count_int int4;
	v_user_active_status_boo BOOLEAN;
	v_user_login_status_boo BOOLEAN;
	
	v_trx_type_int int4 := 1;
	v_balance_before_int int4 := 0;
	v_balance_after_int int4 := 0;
	v_buf_trx_code_txt TEXT := '';
	v_trx_code_txt TEXT := '';
	
	result RECORD;
	
BEGIN	
			
	-- check if phone number isn't registered or duplicate
	SELECT count(*) into v_phone_number_count_int FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if user already active
	SELECT status_active_boo INTO v_user_active_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	-- check if user already login
	SELECT status_login_boo INTO v_user_login_status_boo FROM opm.user_list WHERE phone_number_var = p_phone_number_var;
	
	--if phone number is not registered
		IF v_phone_number_count_int = 0 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Tidak Terdaftar';
			
	-- if phone number is more than one
		ELSIF v_phone_number_count_int > 1 THEN
			v_code_int := 1;
			v_message_var := 'Nomor Telepon Terdaftar Duplikat';

	-- if username not actived
		ELSIF v_user_active_status_boo is FALSE THEN
			v_code_int := 1;
			v_message_var := 'Akun Tidak Aktif';
			
	-- if username not actived
		ELSIF v_user_login_status_boo is FALSE THEN
			v_code_int := 1;
			v_message_var := 'Akun Belum Login';
			
		ELSE
			v_code_int := 0;
			v_message_var := 'Berhasil Topup';
			
			-- topup process
			SELECT usl.balance_int INTO v_balance_before_int from opm.user_list usl WHERE phone_number_var = p_phone_number_var;	
			v_balance_after_int := v_balance_before_int + p_value_int;
			
			-- update balance process			
			UPDATE opm.user_list SET
				balance_int = v_balance_after_int
			WHERE phone_number_var = p_phone_number_var;			
			
			-- compose to trx code
			SELECT format('%1s%2s%3s%4s%5s%6s', 
				to_char(NOW(), 'YYYYMMDDHH24MISS'),
				lpad(v_trx_type_int::VARCHAR, 2, '0'),
				lpad(v_balance_before_int::VARCHAR, 7, '0'),
				lpad(p_value_int::VARCHAR, 7, '0'),
				lpad(v_balance_after_int::VARCHAR, 7, '0'),
				p_phone_number_var
			) into v_buf_trx_code_txt;
			
			SELECT format('%1s%2s', 
				v_buf_trx_code_txt,
				upper(md5(v_buf_trx_code_txt))
			) into v_trx_code_txt;
			
			-- logging
			INSERT INTO opm.trx_topup 
			(
				phone_number_var,
				topup_on_dtm,
				balance_before_int,
				topup_fare_int,
				balance_after_int,
				status_boo,
				desc_status_var,
				topup_transcode_txt
			) 
				VALUES
			(
				p_phone_number_var,				
				TO_TIMESTAMP(to_char(NOW(), 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
				v_balance_before_int,
				p_value_int,
				v_balance_after_int,
				true,
				'ST',
				v_trx_code_txt
			);
		END IF;
		
		SELECT 
			v_code_int,
			v_message_var,
			v_balance_before_int,
			v_balance_after_int,
			v_trx_code_txt
			INTO result;
	
		RETURN RESULT;
END;

$$;
 W   DROP FUNCTION opm.sp_topup(p_phone_number_var character varying, p_value_int integer);
       opm       postgres    false    598    7            ?            1259    34195 	   trx_debit    TABLE     o  CREATE TABLE opm.trx_debit (
    trx_debit_id_seq bigint NOT NULL,
    phone_number_var character varying(20) NOT NULL,
    debit_on_dtm timestamp(6) without time zone,
    balance_before_int integer,
    debit_fare_int integer,
    balance_after_int integer,
    status_boo boolean NOT NULL,
    desc_status_var character varying(2),
    debit_transcode_txt text
);
    DROP TABLE opm.trx_debit;
       opm         postgres    false    7            ?            1259    34193    trx_debit_trx_debit_id_seq_seq    SEQUENCE     ?   CREATE SEQUENCE opm.trx_debit_trx_debit_id_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE opm.trx_debit_trx_debit_id_seq_seq;
       opm       postgres    false    7    198            ?           0    0    trx_debit_trx_debit_id_seq_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE opm.trx_debit_trx_debit_id_seq_seq OWNED BY opm.trx_debit.trx_debit_id_seq;
            opm       postgres    false    197            ?            1259    34180 	   trx_topup    TABLE     o  CREATE TABLE opm.trx_topup (
    trx_topup_id_seq bigint NOT NULL,
    phone_number_var character varying(20) NOT NULL,
    topup_on_dtm timestamp(6) without time zone,
    balance_before_int integer,
    topup_fare_int integer,
    balance_after_int integer,
    status_boo boolean NOT NULL,
    desc_status_var character varying(2),
    topup_transcode_txt text
);
    DROP TABLE opm.trx_topup;
       opm         postgres    false    7            ?            1259    34178    trx_topup_trx_topup_id_seq_seq    SEQUENCE     ?   CREATE SEQUENCE opm.trx_topup_trx_topup_id_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE opm.trx_topup_trx_topup_id_seq_seq;
       opm       postgres    false    195    7            ?           0    0    trx_topup_trx_topup_id_seq_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE opm.trx_topup_trx_topup_id_seq_seq OWNED BY opm.trx_topup.trx_topup_id_seq;
            opm       postgres    false    194            ?            1259    33922 	   user_list    TABLE     f  CREATE TABLE opm.user_list (
    user_list_id_seq bigint NOT NULL,
    user_fullname_var character varying(255) NOT NULL,
    phone_number_var character varying(20) NOT NULL,
    password_var character varying(8) NOT NULL,
    device_name_var character varying(255) NOT NULL,
    email_var character varying(64) NOT NULL,
    photo_base64_txt text,
    balance_int integer NOT NULL,
    register_on_dtm timestamp(6) without time zone NOT NULL,
    status_active_boo boolean NOT NULL,
    status_login_boo boolean NOT NULL,
    desc_status_var character varying(2),
    latitude_flo real,
    longitude_flo real
);
    DROP TABLE opm.user_list;
       opm         postgres    false    7            ?            1259    33920    user_list_user_list_id_seq_seq    SEQUENCE     ?   CREATE SEQUENCE opm.user_list_user_list_id_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE opm.user_list_user_list_id_seq_seq;
       opm       postgres    false    7    187            ?           0    0    user_list_user_list_id_seq_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE opm.user_list_user_list_id_seq_seq OWNED BY opm.user_list.user_list_id_seq;
            opm       postgres    false    186            ?            1259    34264    v_balance_before_int    TABLE     B   CREATE TABLE opm.v_balance_before_int (
    "coalesce" integer
);
 %   DROP TABLE opm.v_balance_before_int;
       opm         postgres    false    7            
           2604    34198    trx_debit trx_debit_id_seq    DEFAULT     ?   ALTER TABLE ONLY opm.trx_debit ALTER COLUMN trx_debit_id_seq SET DEFAULT nextval('opm.trx_debit_trx_debit_id_seq_seq'::regclass);
 F   ALTER TABLE opm.trx_debit ALTER COLUMN trx_debit_id_seq DROP DEFAULT;
       opm       postgres    false    198    197    198            	           2604    34183    trx_topup trx_topup_id_seq    DEFAULT     ?   ALTER TABLE ONLY opm.trx_topup ALTER COLUMN trx_topup_id_seq SET DEFAULT nextval('opm.trx_topup_trx_topup_id_seq_seq'::regclass);
 F   ALTER TABLE opm.trx_topup ALTER COLUMN trx_topup_id_seq DROP DEFAULT;
       opm       postgres    false    194    195    195                       2604    33925    user_list user_list_id_seq    DEFAULT     ?   ALTER TABLE ONLY opm.user_list ALTER COLUMN user_list_id_seq SET DEFAULT nextval('opm.user_list_user_list_id_seq_seq'::regclass);
 F   ALTER TABLE opm.user_list ALTER COLUMN user_list_id_seq DROP DEFAULT;
       opm       postgres    false    186    187    187            ?          0    34195 	   trx_debit 
   TABLE DATA               ?   COPY opm.trx_debit (trx_debit_id_seq, phone_number_var, debit_on_dtm, balance_before_int, debit_fare_int, balance_after_int, status_boo, desc_status_var, debit_transcode_txt) FROM stdin;
    opm       postgres    false    198   >k       ?          0    34180 	   trx_topup 
   TABLE DATA               ?   COPY opm.trx_topup (trx_topup_id_seq, phone_number_var, topup_on_dtm, balance_before_int, topup_fare_int, balance_after_int, status_boo, desc_status_var, topup_transcode_txt) FROM stdin;
    opm       postgres    false    195   Om       ?          0    33922 	   user_list 
   TABLE DATA                 COPY opm.user_list (user_list_id_seq, user_fullname_var, phone_number_var, password_var, device_name_var, email_var, photo_base64_txt, balance_int, register_on_dtm, status_active_boo, status_login_boo, desc_status_var, latitude_flo, longitude_flo) FROM stdin;
    opm       postgres    false    187   Gs       ?          0    34264    v_balance_before_int 
   TABLE DATA               7   COPY opm.v_balance_before_int ("coalesce") FROM stdin;
    opm       postgres    false    199   Et       ?           0    0    trx_debit_trx_debit_id_seq_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('opm.trx_debit_trx_debit_id_seq_seq', 12, true);
            opm       postgres    false    197            ?           0    0    trx_topup_trx_topup_id_seq_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('opm.trx_topup_trx_topup_id_seq_seq', 39, true);
            opm       postgres    false    194            ?           0    0    user_list_user_list_id_seq_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('opm.user_list_user_list_id_seq_seq', 6, true);
            opm       postgres    false    186                       2606    34203    trx_debit trx_debit_pk 
   CONSTRAINT     _   ALTER TABLE ONLY opm.trx_debit
    ADD CONSTRAINT trx_debit_pk PRIMARY KEY (trx_debit_id_seq);
 =   ALTER TABLE ONLY opm.trx_debit DROP CONSTRAINT trx_debit_pk;
       opm         postgres    false    198                       2606    34188    trx_topup trx_topup_pk 
   CONSTRAINT     _   ALTER TABLE ONLY opm.trx_topup
    ADD CONSTRAINT trx_topup_pk PRIMARY KEY (trx_topup_id_seq);
 =   ALTER TABLE ONLY opm.trx_topup DROP CONSTRAINT trx_topup_pk;
       opm         postgres    false    195                       2606    33930    user_list user_list_pk 
   CONSTRAINT     _   ALTER TABLE ONLY opm.user_list
    ADD CONSTRAINT user_list_pk PRIMARY KEY (user_list_id_seq);
 =   ALTER TABLE ONLY opm.user_list DROP CONSTRAINT user_list_pk;
       opm         postgres    false    187            ?     x???[r?0E??Ut??E ??h????
%?Բ;҈Q$?xA???X???/H?D;?.?n??ۯ?o0??\???-?{???%Ͱ??ث?2??j\?????>W@~(`?3m?Q?7|r"?L|????͂1?3M)??%K?F'@??s??????|??f?&A<?f
:*{??J???|?/??O??>q,?u V?Z???+????;?7:<???m8?sSk鵶?y?????>?MK??/??fa@}????D?????8k?d,}റ,?$?????A??|~~?????????d%g-0&]???2J?=?+?????#??|?ˉ_uL???f???t????Ry???7??_|>??kl????b???g?*-WM????! dg?3@?/p??????(??7UVv???u??	??#mx?????5x:?Tb͚?Jmc!?*6?q?37????????G?>?p??I?]rw?(??#?3c?A?W??L~???2?0?      ?   ?  x???Kr?:E??*jՁ?????e???/??E?K?C????{?I??L,j?r?7?L??G??|??N~#????n????????#??A???W?O?l??fM=??[]?R?l?g??? ??#8^҉ =b?	?~?%??????Y#?&?#OrIP?T?? ?'?B?sO??SVK.??h?b?#-?6)cuD$???l?AP?	??<b?	?~?"???_?밒???4#-Rʥ?$????????>b?8???d?4?8???bⴆ?1?_???-8?D?5?b?	h?eg*???hX?12??Q??d?_?/	?wአ?ꖘ?????`?y7?????v!o????]ȏ??Ǒ?N]??K????T??A?????? ??~{>Ǉ??!???_iu?^f[F??\f&?j?ſ ?bS???	???݄?U??SM?i??e?xA??=??_? ?Y?`?r?{??u???0?? ?? Ȫo p?X??V!5Kؙ?ρ^???^? ????]6~8!??Z?C&?B?q?v?` ?y?g ??G)??a?Y|???Q?,????@/???/?s?'?)??t??J?(J?{?d?b?P?3???Xaykz?"ⓤ???fJq?9?Q?????o ???zxȐ??'T??F)c?]+?h8??h?K+? ?K??@cƴVm???"?1iޠt8??	??L~P? ??,0x??Us\sT?Xڨ??tBѻğe(*??b?t?Y?\?eoH?E?0? _:? ??I?"???ᐄ???Ȏ?&ל?-þ?8N+?t?@?n??>m??O???p?"?2
?4?6lfhB?q+?-?t?O?m?9???!FB"??0&x???WK^j?2G|???!8?? {???!	?8q????P?$yaE???N?	??~p???;??#?1???????@???? ~ۺ????B???A??q?x?grC??j^?I??*8;!JB???B4O2??O`#?2\+?ap?=y-8?|vZ???p??A?_ ??]?p???G? ??E?v,jZQ??p?1>?? Q|G?;Jat&:?m?n??dZH? g'??;??(?/???v??䙰?h?z?{?s??eCI???G e? ?VC????K6-???Rs5A?N??U??d?	?>??3?n?"[??~p?<??+zwO???	? ?u&G~?w_r%Êcȳ??5?Ögw???\ ??????????(? T??ڨ?e!	}????@V????G ??v? ?L!? ?????k`????%???itU?drv?=??Q6o??	?I!? ?[?[???P\tpEF?\e?????	? ???-?g???С9D9Tf?
s?BY?8?\(??E9ȅ~?+B]Nf???p????˓?|:?1?j?J>?X?^????r?iA^???"tǶ???80ڎ?w???ςn?';j9A>???7b??O??[???      ?   ?   x?E??N?0???S???NZ?????\"??i??j??xz2?4Y??,??^?4?&gS?w?V?6??7?????`??>???g??L?!??s?? ?'?	:??
?cL:^?[?\??l????;=??#?^K?^o? ?a?T*??
[????x ??a?~d?SⓃ?)?????)???3)???λ??E#|??ί?g???w>??©?mU?????xAIm???KK?Du?&???frW{      ?      x?34?????? ?     