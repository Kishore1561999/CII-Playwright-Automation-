--
-- PostgreSQL database dump
--

-- Dumped from database version 13.7 (Ubuntu 13.7-0ubuntu0.21.10.1)
-- Dumped by pg_dump version 14.13 (Ubuntu 14.13-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: data_collection_company_details; Type: TABLE; Schema: public; Owner: spritle
--

CREATE TABLE public.data_collection_company_details (
    id bigint NOT NULL,
    company_name character varying,
    company_isin_number character varying,
    company_sector character varying,
    analyst_user_id integer,
    status character varying,
    upload_status character varying,
    create_user_id integer,
    update_user_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_type character varying,
    subscription_services character varying,
    selected_year character varying,
    company_update_user_id integer
);


ALTER TABLE public.data_collection_company_details OWNER TO spritle;

--
-- Name: data_collection_company_details_id_seq; Type: SEQUENCE; Schema: public; Owner: spritle
--

CREATE SEQUENCE public.data_collection_company_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.data_collection_company_details_id_seq OWNER TO spritle;

--
-- Name: data_collection_company_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spritle
--

ALTER SEQUENCE public.data_collection_company_details_id_seq OWNED BY public.data_collection_company_details.id;


--
-- Name: data_collection_company_details id; Type: DEFAULT; Schema: public; Owner: spritle
--

ALTER TABLE ONLY public.data_collection_company_details ALTER COLUMN id SET DEFAULT nextval('public.data_collection_company_details_id_seq'::regclass);


--
-- Data for Name: data_collection_company_details; Type: TABLE DATA; Schema: public; Owner: spritle
--

COPY public.data_collection_company_details (id, company_name, company_isin_number, company_sector, analyst_user_id, status, upload_status, create_user_id, update_user_id, created_at, updated_at, user_type, subscription_services, selected_year, company_update_user_id) FROM stdin;
95	CII_ABB India Ltd		Capital Goods	1	submitted	Prefill	\N	1	2024-08-05 11:46:56.031011	2024-08-05 12:53:43.203552	cii_user	premium	2024	\N
104	CII_Oil & Natural Gas Corporation Limited		Oil, Gas & Consumablefuels	1	submitted	Prefill	\N	1	2024-08-09 06:31:16.969864	2024-08-09 07:06:37.771848	cii_user	premium	2024	\N
152	CII_Relaxo Footwears Limited		Consumer Durables	59	submitted	Prefill	\N	59	2024-08-14 10:55:02.20738	2024-08-14 17:26:21.419565	cii_user	\N	2024	\N
105	CII_Ramkrishna Forgings Limited		Automobiles & Auto Components	1	submitted	Prefill	\N	1	2024-08-09 07:08:49.736984	2024-08-09 07:46:27.797279	cii_user	premium	2024	\N
108	CII_VST Industries Limited		FMCG	1	submitted	Prefill	\N	1	2024-08-09 09:08:42.218978	2024-08-09 09:54:03.965685	cii_user	premium	2024	\N
103	CII_Jio Financial Services Limited		Financial Services	1	submitted	Prefill	\N	1	2024-08-09 04:20:50.725855	2024-08-09 11:31:06.545849	cii_user	premium	2024	\N
115	CII_Thirumalai Chemicals Limited		Chemicals	60	submitted	Prefill	\N	60	2024-08-12 10:02:01.708946	2024-08-13 09:15:37.065282	cii_user	\N	2024	\N
83	CII_Polycab India Limited		Capital Goods	1	wip	Prefill	\N	1	2024-07-25 08:59:02.15477	2024-08-21 06:18:27.712158	cii_user	premium	\N	\N
110	CII_Everest Kanto Cylinder Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-08-09 11:33:10.328148	2024-08-09 11:55:56.863076	cii_user	premium	2024	\N
163	CII_EMAMI LIMITED		FMCG	59	submitted	Prefill	\N	59	2024-08-16 03:36:52.977421	2024-08-16 04:14:12.342782	cii_user	\N	2024	\N
190	CII_CEAT Limited 		Automobiles & Auto Components	59	submitted	Prefill	\N	59	2024-08-17 11:56:51.868023	2024-08-21 05:27:57.663094	cii_user	\N	2024	\N
113	CII_Motherson Sumi Wiring India Limited		Automobiles & Auto Components	1	submitted	Prefill	\N	1	2024-08-09 12:42:59.608611	2024-08-09 13:01:27.479167	cii_user	premium	2024	\N
128	CII_Foseco India Limited		Chemicals	1	submitted	Prefill	\N	1	2024-08-13 09:24:07.511413	2024-08-13 10:06:47.832757	cii_user	premium	2024	\N
154	CII_GM Breweries Limited		FMCG	1	submitted	Prefill	\N	1	2024-08-14 12:37:52.105493	2024-08-14 12:58:32.593253	cii_user	premium	2024	\N
133	CII_Delhivery Limited		Services	59	submitted	Prefill	\N	59	2024-08-13 13:44:18.933289	2024-08-21 12:42:32.304269	cii_user	\N	2024	\N
180	CII_TITAGARH RAIL SYSTEMS LIMITED		Capital Goods	59	submitted	Prefill	\N	59	2024-08-16 12:36:16.618999	2024-08-21 15:45:20.079558	cii_user	\N	2024	\N
165	CII_IndusInd Bank Limited		Financial Services	59	submitted	Prefill	\N	59	2024-08-16 04:59:15.452813	2024-08-18 07:36:32.16323	cii_user	\N	2024	\N
130	CII_Sirca paint india limited		Consumer Durables	59	submitted	Prefill	\N	59	2024-08-13 12:35:21.766656	2024-08-21 11:51:32.683856	cii_user	\N	2024	\N
141	CII_RAIN INDUSTRIES LIMITED		Chemicals	1	submitted	Prefill	\N	1	2024-08-14 05:34:56.183938	2024-08-14 06:21:22.60263	cii_user	premium	2023	\N
148	CII_Craftsman Automation Limited		Automobiles & Auto Components	1	submitted	Prefill	\N	1	2024-08-14 08:03:44.640921	2024-08-14 08:42:52.466314	cii_user	premium	2024	\N
123	CII_Honda India Power Products Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-08-13 05:54:36.398391	2024-08-13 06:13:02.726903	cii_user	premium	2024	\N
199	CII_Jindal Stainless Limited		Metals & Mining	60	submitted	Prefill	\N	60	2024-08-19 19:55:37.227153	2024-08-20 14:01:51.610401	cii_user	\N	2024	\N
124	CII_Refex Industries Limited		Chemicals	1	submitted	Prefill	\N	1	2024-08-13 06:17:57.973125	2024-08-13 07:22:26.416934	cii_user	premium	2024	\N
150	CII_Schaeffler India Limited		Automobiles & Auto Components	1	submitted	Prefill	\N	1	2024-08-14 08:48:18.131684	2024-08-14 09:14:05.705587	cii_user	premium	2023	\N
121	CII_IG Petrochemicals Limited		Chemicals	60	submitted	Prefill	\N	60	2024-08-13 03:46:46.754533	2024-08-14 13:49:53.312431	cii_user		2024	\N
178	CII_Globus Spirits Limited		FMCG	59	submitted	Prefill	\N	59	2024-08-16 11:45:27.734766	2024-08-21 15:56:27.212436	cii_user	\N	2024	\N
143	CII_Sanofi India Limited		Healthcare	1	submitted	Prefill	\N	1	2024-08-14 06:56:04.223495	2024-08-14 07:24:05.182805	cii_user	premium	2023	\N
193	CII_ION Exchange (India) Limited		Utilities	60	submitted	Prefill	\N	60	2024-08-18 16:51:34.621671	2024-08-18 20:15:56.745643	cii_user	\N	2024	\N
196	CII_Shyam Metalics and Energy Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-18 16:56:59.766689	2024-08-20 12:49:59.613129	cii_user	\N	2024	\N
126	CII_Petronet LNG Limited		Oil, Gas & Consumablefuels	60	submitted	Prefill	\N	60	2024-08-13 09:09:27.820466	2024-08-14 17:26:00.05238	cii_user	\N	2024	\N
135	CII_Bharat Bijlee Limited		Capital Goods	59	submitted	Prefill	\N	59	2024-08-13 16:36:44.496609	2024-08-16 07:27:09.823554	cii_user	premium	2024	\N
173	CII_Honasa Consumer Ltd		FMCG	59	submitted	Prefill	\N	59	2024-08-16 07:36:56.521393	2024-08-18 08:12:34.109664	cii_user	\N	2024	\N
192	CII_Gandhar Oil Refinery (India) Limited		Oil, Gas & Consumablefuels	60	submitted	Prefill	\N	60	2024-08-18 16:48:00.119706	2024-08-18 17:34:40.663849	cii_user	\N	2024	\N
116	CII_Clean Science and Technology Limited		Chemicals	59	submitted	Prefill	\N	59	2024-08-12 10:41:17.491064	2024-08-21 05:15:06.311904	cii_user		2024	\N
182	CII_UPL Limited 		Chemicals	59	submitted	Prefill	\N	59	2024-08-17 07:08:57.29612	2024-08-17 07:45:35.816501	cii_user	\N	2024	\N
189	CII_Coforage Limited 		Information Technology	59	submitted	Prefill	\N	59	2024-08-17 11:53:53.553787	2024-08-17 12:38:36.08907	cii_user	\N	2024	\N
195	CII_Dynamatic Technologies Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-18 16:55:44.381189	2024-08-19 06:26:20.414264	cii_user	\N	2024	\N
186	CII_Borosil Renewables Limited		Capital Goods	59	submitted	Prefill	\N	59	2024-08-17 09:21:40.433532	2024-08-21 06:28:54.022261	cii_user	\N	2024	\N
138	CII_The Federal Bank  Limited		Financial Services	60	submitted	Prefill	\N	60	2024-08-13 20:58:28.939595	2024-08-20 14:07:15.616661	cii_user	premium	2024	\N
197	CII_Vijaya Diagnostic Centre Limited		Healthcare	60	submitted	Prefill	\N	60	2024-08-18 16:58:19.301253	2024-08-18 18:37:57.512514	cii_user	\N	2024	\N
194	CII_Suzlon Energy Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-18 16:53:59.923159	2024-08-20 15:47:36.275974	cii_user	\N	2024	\N
200	CII_AIA Engineering Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-19 20:30:52.045196	2024-08-20 16:27:09.714726	cii_user	\N	2024	\N
119	CII_Jain Irrigation system limited 		Capital Goods	59	submitted	Prefill	\N	59	2024-08-12 13:36:48.62918	2024-08-21 07:03:19.849013	cii_user	\N	2024	\N
202	CII_Electrosteel Castings Limited		Capital Goods	59	submitted	Prefill	\N	59	2024-08-20 04:29:45.709857	2024-08-20 05:23:29.088847	cii_user	\N	2024	\N
204	CII_Rossari Biotech Limited		Chemicals	59	submitted	Prefill	\N	59	2024-08-20 06:01:02.027782	2024-08-20 06:40:28.611716	cii_user	\N	2024	\N
184	CII_Astra Microwave Products Limited 		Capital Goods	59	submitted	Prefill	\N	59	2024-08-17 08:31:23.601213	2024-08-20 09:28:20.541808	cii_user	\N	2024	\N
82	CII_Supreme Industries Limited		Capital Goods	1	wip	Prefill	\N	1	2024-07-25 08:56:33.978207	2024-07-25 08:57:59.674813	cii_user	premium	\N	\N
125	CII_R Systems International Limited		Information Technology	1	submitted	Prefill	\N	1	2024-08-13 07:26:54.668711	2024-08-13 08:54:57.163049	cii_user	premium	2024	\N
203	CII_CSB Bank Limited		Financial Services	59	submitted	Prefill	\N	59	2024-08-20 05:25:39.940537	2024-08-20 05:59:36.457598	cii_user	\N	2024	\N
85	CII_Cummins India Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-07-25 09:04:23.781776	2024-08-06 06:57:28.937637	cii_user	premium	\N	\N
151	CII_ICICI Bank Limited		Financial Services	59	submitted	Prefill	\N	59	2024-08-14 09:06:42.212434	2024-08-14 10:32:33.686818	cii_user	\N	2024	\N
106	CII_SANGHVI MOVERS LIMITED		Capital Goods	1	submitted	Prefill	\N	1	2024-08-09 08:08:07.225322	2024-08-09 08:37:01.030391	cii_user	premium	2024	\N
99	CII_LIC Housing Finance Limited		Financial Services	1	submitted	Prefill	\N	1	2024-08-07 09:11:31.853585	2024-08-07 09:58:04.367162	cii_user	premium	2024	\N
159	CII_Godfrey Phillips India Limited		FMCG	60	submitted	Prefill	\N	60	2024-08-14 17:36:06.154727	2024-08-15 15:24:37.270093	cii_user	\N	2024	\N
107	CII_Gland Pharma Limited		Healthcare	1	submitted	Prefill	\N	1	2024-08-09 08:40:53.717535	2024-08-09 09:05:55.749696	cii_user	premium	2024	\N
102	CII_Pfizer Limited		Healthcare	1	submitted	Prefill	\N	1	2024-08-08 03:35:40.298236	2024-08-08 04:29:09.095132	cii_user	premium	2024	\N
157	CII_Surya Roshni Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-14 17:30:12.414136	2024-08-15 05:39:47.188242	cii_user	\N	2024	\N
109	CII_Aster DM Healthcare Limited		Healthcare	1	submitted	Prefill	\N	1	2024-08-09 10:02:31.371832	2024-08-09 11:20:09.44917	cii_user	premium	2024	\N
101	CII_Reliance Industries Limited		Oil, Gas and Consumable Fuels	1	submitted	Prefill	\N	1	2024-08-08 03:30:03.078279	2024-08-09 04:15:31.644397	cii_user	premium	2024	\N
181	CII_India Glycols Limited		Chemicals	59	submitted	Prefill	\N	59	2024-08-17 06:15:56.807271	2024-08-21 15:30:27.189592	cii_user	\N	2024	\N
120	CII_Jaiprakash Power Ventures Limited		Power	60	submitted	Prefill	\N	60	2024-08-13 02:33:16.967201	2024-08-21 14:33:41.50633	cii_user	\N	2024	\N
111	CII_Maharashtra Seamless Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-08-09 11:58:20.586129	2024-08-09 12:18:11.252866	cii_user	premium	2024	\N
131	CII_Esab India Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-13 13:10:20.636062	2024-08-14 22:47:30.311099	cii_user	\N	2024	\N
112	CII_Jindal Drilling And Industries Limited		Oil, Gas & Consumablefuels	1	submitted	Prefill	\N	1	2024-08-09 12:20:32.344096	2024-08-09 12:39:45.626131	cii_user	premium	2024	\N
132	CII_Samvardhana Motherson International Limited		Automobiles & Auto Components	60	submitted	Prefill	\N	60	2024-08-13 13:11:56.427151	2024-08-14 13:59:25.687844	cii_user	\N	2024	\N
122	CII_IDFC First Bank Limited		Financial Services	1	submitted	Prefill	\N	1	2024-08-13 05:22:46.25661	2024-08-13 05:50:34.880982	cii_user	premium	2024	\N
142	CII_Transformers and Rectifiers (India) Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-08-14 06:25:04.811588	2024-08-14 06:53:47.802257	cii_user	premium	2024	\N
114	CII_DMCC Speciality Chemicals Limited		Chemicals	1	submitted	Prefill	\N	1	2024-08-12 03:57:28.422677	2024-08-12 07:43:40.116895	cii_user	premium	2024	\N
145	CII_Hindware Home Innovation limited 		Consumer Durables	59	submitted	Prefill	\N	59	2024-08-14 07:11:38.041714	2024-08-21 13:00:49.423303	cii_user	\N	2024	\N
136	CII_Manorama Industries Limited		FMCG	60	submitted	Prefill	\N	60	2024-08-13 20:45:22.867203	2024-08-14 23:24:36.371996	cii_user	\N	2024	\N
118	CII_Narayana Hrudayalaya limited		Healthcare	59	submitted	Prefill	\N	59	2024-08-12 12:01:53.550215	2024-08-14 04:13:39.2165	cii_user	\N	2024	\N
158	CII_Kajaria Ceramics Limited		Consumer Durables	60	submitted	Prefill	\N	60	2024-08-14 17:34:09.290225	2024-08-20 15:12:09.710354	cii_user	\N	2024	\N
137	CII_Jyoti Structures Limited		Capital Goods	60	submitted	Prefill	\N	60	2024-08-13 20:46:43.229176	2024-08-15 04:06:42.040234	cii_user	\N	2024	\N
179	CII_Equitas Small Finance Bank Limited		Financial Services	60	submitted	Prefill	\N	60	2024-08-16 12:20:51.000071	2024-08-20 14:49:44.997754	cii_user	\N	2024	\N
149	CII_Expleo solutions Limited		Information Technology	59	submitted	Prefill	\N	59	2024-08-14 08:31:37.068686	2024-08-21 16:11:34.804171	cii_user	premium	2024	1
139	CII_CRISIL Limited		Financial Services	1	submitted	Prefill	\N	1	2024-08-14 04:44:55.348022	2024-08-14 05:30:50.796345	cii_user	premium	2023	\N
146	CII_Huhtamaki India Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-08-14 07:26:09.868501	2024-08-14 08:00:28.462658	cii_user	premium	2023	\N
177	CII_PI Industries Limited		Chemicals	59	submitted	Prefill	\N	59	2024-08-16 09:06:09.984898	2024-08-16 10:57:51.608187	cii_user	\N	2024	\N
183	CII_IOL Chemicals and Pharmaceuticals Limited		Healthcare	59	submitted	Prefill	\N	59	2024-08-17 07:49:17.482335	2024-08-17 08:29:29.960039	cii_user	\N	2024	\N
161	CII_Sigachi Industries Limited		Healthcare	60	submitted	Prefill	\N	60	2024-08-14 17:42:13.710737	2024-08-15 13:36:32.969668	cii_user	\N	2024	\N
164	CII_Aurobindo Pharma Limited		Healthcare	59	submitted	Prefill	\N	59	2024-08-16 04:19:18.055976	2024-08-16 04:56:09.869216	cii_user	\N	2024	\N
160	CII_Rolex Rings Limited		Automobiles & Auto Components	60	submitted	Prefill	\N	60	2024-08-14 17:39:47.129772	2024-08-15 04:41:59.206525	cii_user	\N	2024	\N
175	CII_L.G. BALAKRISHNAN & BROS LIMITED		Automobiles & Auto Components	59	submitted	Prefill	\N	59	2024-08-16 08:22:39.713838	2024-08-16 11:38:55.823523	cii_user	\N	2024	\N
191	CII_FORCE MOTORS LTD		Capital Goods	60	submitted	Prefill	\N	60	2024-08-18 15:53:34.61297	2024-08-20 14:44:47.739717	cii_user	\N	2024	\N
187	CII_KFIN Technologies Limited		Financial Services	59	submitted	Prefill	\N	59	2024-08-17 10:17:10.400223	2024-08-20 10:21:03.990974	cii_user	\N	2024	59
134	CII_Krishna Institute of Medical Sciences Limited		Healthcare	59	submitted	Prefill	\N	59	2024-08-13 15:51:50.633633	2024-08-21 12:23:38.180918	cii_user	\N	2024	\N
185	CII_Hindustan Aeronautics Limited		Capital Goods	59	submitted	Prefill	\N	59	2024-08-17 08:58:07.807336	2024-08-17 09:19:56.093619	cii_user	\N	2024	\N
188	CII_Thyrocare Technologies Limited		Healthcare	59	submitted	Prefill	\N	59	2024-08-17 11:02:16.025183	2024-08-17 11:52:13.560923	cii_user	\N	2024	\N
162	CII_Asahi India Glass Limited		Automobiles & Auto Components	60	submitted	Prefill	\N	60	2024-08-14 17:44:26.426939	2024-08-20 15:15:44.431268	cii_user	\N	2024	\N
127	CII_Gujarat Ambuja Exports Limited		FMCG	59	submitted	Prefill	\N	59	2024-08-13 09:16:38.779564	2024-08-21 05:55:59.515068	cii_user	\N	2024	\N
198	CII_Vesuvius India Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-08-19 15:54:20.325305	2024-08-20 04:47:19.02417	cii_user	premium	2023	\N
84	CII_CG Power and Industrial Solutions Limited		Capital Goods	1	submitted	Prefill	\N	1	2024-07-25 09:01:59.847586	2024-08-20 05:57:14.171297	cii_user	premium	\N	\N
225	CII_MAS Financial Services Limited		Financial Services	60	\N	\N	60	\N	2024-08-20 20:47:56.898989	2024-08-20 20:47:56.952596	cii_user	\N	2024	\N
226	CII_BLS E-Services Limited		Information Technology	60	\N	\N	60	\N	2024-08-20 20:48:51.497803	2024-08-20 20:48:54.20568	cii_user	\N	2024	\N
227	CII_Quick Heal Technologies Limited		Information Technology	60	\N	\N	60	\N	2024-08-20 21:02:49.573371	2024-08-20 21:02:51.476327	cii_user	\N	2024	\N
205	CII_Flair Writing Industries Limited		FMCG	59	submitted	Prefill	\N	59	2024-08-20 06:41:52.552384	2024-08-20 07:23:34.761149	cii_user	\N	2024	\N
206	CII_APAR Industries Limited		Capital Goods	59	submitted	Prefill	\N	59	2024-08-20 06:43:29.108698	2024-08-20 08:07:07.171926	cii_user	\N	2024	\N
228	CII_Parag Milk Foods Limited		FMCG	60	\N	\N	60	\N	2024-08-20 21:04:17.548606	2024-08-20 21:04:17.597578	cii_user	\N	2024	\N
229	CII_Medicamen Biotech Limited		Healthcare	60	\N	\N	60	\N	2024-08-20 21:05:08.263526	2024-08-20 21:05:08.324504	cii_user	\N	2024	\N
207	CII_Styrenix Performance Materials Limited		Chemicals	59	submitted	Prefill	\N	59	2024-08-20 06:44:33.647596	2024-08-20 09:23:03.045131	cii_user	\N	2024	\N
214	CII_Ircon International Limited		Constructions	60	submitted	Prefill	60	60	2024-08-20 17:17:34.78086	2024-08-20 18:30:06.798846	cii_user	\N	2024	\N
129	CII_JUBILANT INGREVIA LIMITED		Chemicals	59	submitted	Prefill	\N	59	2024-08-13 11:04:11.86337	2024-08-20 10:14:46.948791	cii_user	\N	2024	\N
230	CII_Shivalik Rasayan Limited		Chemicals	60	\N	\N	60	\N	2024-08-20 21:08:31.849186	2024-08-20 21:08:31.897157	cii_user	\N	2024	\N
217	CII_Sterling and Wilson Renewable Energy Limited		Constructions	60	submitted	Prefill	60	60	2024-08-20 18:07:23.345758	2024-08-20 19:10:00.866265	cii_user	\N	2024	\N
208	CII_EPL Limited		Capital Goods	59	submitted	Prefill	\N	59	2024-08-20 06:45:45.654674	2024-08-20 11:07:53.766829	cii_user	\N	2024	\N
231	CII_Renaissance Global Limited		Consumer Durables	60	\N	\N	60	\N	2024-08-20 21:10:33.848391	2024-08-20 21:10:34.850591	cii_user	\N	2024	\N
209	CII_Metropolis Healthcare Limited		Healthcare	59	submitted	Prefill	\N	59	2024-08-20 06:47:18.692373	2024-08-20 11:52:19.93772	cii_user	\N	2024	\N
233	CII_RSWM Limited		Textiles	60	submitted	Prefill	60	60	2024-08-20 21:12:12.735505	2024-08-21 21:35:10.396154	cii_user	\N	2024	\N
215	CII_NCC Limited		Constructions	60	submitted	Prefill	60	60	2024-08-20 18:06:15.346935	2024-08-20 20:39:26.54472	cii_user	\N	2024	\N
211	CII_CITY UNION BANK LIMITED		Financial Services	59	submitted	Prefill	\N	59	2024-08-20 06:49:34.064259	2024-08-20 12:49:55.005801	cii_user	\N	2024	\N
210	CII_KPIT Technologies Limited		Information Technology	59	submitted	Prefill	\N	59	2024-08-20 06:48:44.614338	2024-08-20 12:52:31.694362	cii_user	\N	2024	\N
220	CII_Jamna Auto Industries Limited		Automobiles & Auto Components	60	\N	\N	60	\N	2024-08-20 20:44:21.046808	2024-08-20 20:44:21.404824	cii_user	\N	2024	\N
221	CII_Prince Pipes And Fittings Limited		Capital Goods	60	\N	\N	60	\N	2024-08-20 20:45:05.621811	2024-08-20 20:45:05.66097	cii_user	\N	2024	\N
213	CII_Vinati Organics Limited		Chemicals	60	submitted	Prefill	60	60	2024-08-20 16:39:38.394381	2024-08-20 17:12:05.492713	cii_user	\N	2024	\N
222	CII_India Tourism Development Corporation Limited		Consumer Services	60	\N	\N	60	\N	2024-08-20 20:45:55.712998	2024-08-20 20:45:55.758842	cii_user	\N	2024	\N
223	CII_Mtar Technologies Limited		Capital Goods	60	\N	\N	60	\N	2024-08-20 20:46:53.582913	2024-08-20 20:46:54.993806	cii_user	\N	2024	\N
224	CII_MAS Financial Services Limited		Financial Services	60	\N	\N	60	\N	2024-08-20 20:47:55.599837	2024-08-20 20:47:55.666874	cii_user	\N	2024	\N
234	CII_EPACK Durable Limited		Consumer Services	60	submitted	Prefill	60	60	2024-08-20 21:16:13.668392	2024-08-21 21:01:25.918769	cii_user	\N	2024	\N
235	CII_RADIANT CASH MANAGEMENT SERVICES LIMITED		Services	60	submitted	Prefill	60	60	2024-08-20 21:17:59.570376	2024-08-21 20:44:53.244796	cii_user	\N	2024	\N
236	CII_DHAMPUR SUGAR MILLS LIMITED		FMCG	60	submitted	Prefill	60	60	2024-08-20 21:19:44.892405	2024-08-21 15:05:03.20221	cii_user	\N	2024	\N
218	CII_Engineers India Limited		Constructions	60	submitted	Prefill	60	60	2024-08-20 20:41:15.859566	2024-08-20 21:46:02.53872	cii_user	\N	2024	\N
216	CII_G R Infraprojects Limited		Constructions	60	wip	Prefill	60	60	2024-08-20 18:06:40.03512	2024-08-21 14:30:04.304359	cii_user	\N	2024	\N
249	CII_Triveni Engineering & Industries Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 07:23:10.727042	2024-08-21 08:48:20.396018	cii_user	premium	2024	\N
259	CII_Balrampur Chini Mills Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 08:53:11.671874	2024-08-21 10:49:32.343035	cii_user	premium	2024	\N
245	CII_Dalmia Bharat Sugar and Industries Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 06:25:46.746609	2024-08-21 10:15:57.602664	cii_user	premium	2024	1
242	CII_INOX INDIA LIMITED		Capital Goods	1	submitted	Prefill	1	1	2024-08-21 04:23:12.21552	2024-08-21 04:48:29.657648	cii_user	premium	2024	\N
237	CII_TEGA INDUSTRIES LIMITED		Capital Goods	59	submitted	Prefill	59	59	2024-08-21 03:31:02.349786	2024-08-21 04:48:43.357928	cii_user	\N	2024	\N
244	CII_Britannia Industries Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 05:32:40.66959	2024-08-21 05:53:25.184975	cii_user	premium	2024	\N
243	CII_Tata Consumer Products Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 04:51:01.000861	2024-08-21 05:29:50.275237	cii_user	premium	2024	\N
238	CII_KALYANI STEELS LIMITED		Capital Goods	59	submitted	Prefill	59	59	2024-08-21 03:31:47.883535	2024-08-21 06:58:56.022694	cii_user	\N	2024	\N
265	CII_Adani Wilmar Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 10:55:33.088664	2024-08-21 11:17:05.022539	cii_user	premium	2024	\N
246	CII_Bajaj Hindusthan Sugar Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 07:01:47.690443	2024-08-21 08:15:38.059134	cii_user	premium	2024	\N
239	CII_REC Limited		Financial Services	59	submitted	Prefill	59	59	2024-08-21 03:32:39.716385	2024-08-21 07:35:25.16559	cii_user	\N	2024	\N
219	CII_Aether Industries Limited		Chemicals	60	submitted	Prefill	60	60	2024-08-20 20:42:27.163897	2024-08-21 14:29:22.030674	cii_user	\N	2024	\N
266	CII_Marico Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 11:19:56.99659	2024-08-21 11:57:30.241257	cii_user	premium	2024	\N
232	CII_Nandan Denim Limited		Textiles	60	wip	\N	60	\N	2024-08-20 21:11:35.311971	2024-08-21 21:41:41.605221	cii_user	\N	2024	\N
240	CII_India Pesticides Limited		Chemicals	59	submitted	Prefill	59	59	2024-08-21 03:33:50.713369	2024-08-21 11:21:03.188758	cii_user	\N	2024	\N
147	CII_Indian Railway Finance Corporation LTD		Financial Services	59	wip	Prefill	\N	59	2024-08-14 07:38:51.712768	2024-08-21 13:04:27.69353	cii_user	\N	2024	\N
267	CII_Sula Vineyards Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 12:02:19.773574	2024-08-21 12:46:11.87207	cii_user	premium	2024	\N
268	CII_Radico Khaitan Limited		FMCG	1	submitted	Prefill	1	1	2024-08-21 12:48:43.764884	2024-08-21 13:39:12.837159	cii_user	premium	2024	\N
272	CII_HATSUN AGRO PRODUCT LIMITED		FMCG	59	\N	\N	59	\N	2024-08-22 02:03:50.310741	2024-08-22 02:03:50.342499	cii_user	\N	2024	\N
273	CII_BHARAT HEAVY ELECTRICALS LIMITED		Capital Goods	59	\N	\N	59	\N	2024-08-22 02:04:42.523908	2024-08-22 02:04:42.556935	cii_user	\N	2024	\N
274	CII_TTK Prestige Limited		Consumer Durables	59	\N	\N	59	\N	2024-08-22 02:05:27.551371	2024-08-22 02:05:27.580693	cii_user	\N	2024	\N
241	CII_Kotak Mahindra Bank Limited		Financial Services	59	submitted	Prefill	59	59	2024-08-21 03:34:42.323724	2024-08-22 02:15:49.167707	cii_user	\N	2024	\N
269	CII_Life Insurance Corporation of India		Financial Services	59	submitted	Prefill	59	59	2024-08-22 02:00:45.90493	2024-08-22 02:54:17.083716	cii_user	\N	2024	\N
270	CII_Bandhan Bank limited		Financial Services	59	submitted	Prefill	59	59	2024-08-22 02:01:43.197587	2024-08-22 03:19:52.189963	cii_user	\N	2024	\N
271	CII_Max Financial Services Limited		Financial Services	59	submitted	Prefill	59	59	2024-08-22 02:02:52.823001	2024-08-22 03:58:20.199925	cii_user	\N	2024	\N
\.


--
-- Name: data_collection_company_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spritle
--

SELECT pg_catalog.setval('public.data_collection_company_details_id_seq', 274, true);


--
-- Name: data_collection_company_details data_collection_company_details_pkey; Type: CONSTRAINT; Schema: public; Owner: spritle
--

ALTER TABLE ONLY public.data_collection_company_details
    ADD CONSTRAINT data_collection_company_details_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

