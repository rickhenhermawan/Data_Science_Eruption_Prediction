# Data dan Prediksi Erupsi Gunung Berapi di Seluruh Dunia Hingga Tahun 2018

Pada repositori ini berisi aplikasi shiny yang dibuat menggunakan bahasa pemrograman R untuk menunjukkan data erupsi yang sudah terjadi dan prediksi erupsi yang ada pada tahun 2018. Kami mengambil sumber data erupsi yang sudah ada dan telah terjadi sebelumnya berdasarkan data yang tersedia di National Centers for Environmental Information  [NOAA](https://www.ngdc.noaa.gov/nndc/struts/results?ge_23=&le_23=&type_15=Like&query_15=&op_30=eq&v_30=&type_16=Like&query_16=&op_29=eq&v_29=&type_31=EXACT&query_31=None+Selected&le_17=&ge_18=&le_18=&ge_17=&op_20=eq&v_20=&ge_7=&le_7=&bt_24=&st_24=&ge_25=&le_25=&bt_26=&st_26=&ge_27=&le_27=&type_13=Like&query_13=&type_12=Exact&query_12=&type_11=Exact&query_11=&display_look=50&t=102557&s=50). 


## Dependensi

- [R versi 3.5](https://cran.r-project.org/bin/windows/base/)

- [Google Chrome](https://www.google.com/intl/id_ALL/chrome/) / Browser Lainnya

- [Excel](https://docs.google.com/document/d/1baA9E5ciLhOmI-0TkWy9WpAOXH8sxLv4-at5e28FrbM/edit)

- [Zamzar-Free Online File Conversion](https://www.zamzar.com/)

## Instalasi

- Kloning repo ini, lalu cd ke direktori tempat repo ini dikloning
- Jalankan R atau RStudio
- Instal beberapa package yang dibutuhkan, seperti:
  - packages(&#39;ggedit&#39;)
  - packages(&#39;shiny&#39;)
  - packages(&#39;shinyAce&#39;)
  - packages(&#39;ggplot2&#39;)
  - packages(&#39;prophet&#39;)
  - packages(&#39;rpart&#39;)
  - packages(&#39;plotly&#39;)
- Jalankan app Shiny dari [app.R](https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/app.R)
- Ubah direktori file=&quot;C:/.../VolcanoData.csv&quot; dengan menyesuaikan alamat tempat anda menaruh repositori ini untuk mengambil data erupsi yang telah terjadi


## Cara Kerja
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/Blank%20Diagram.png"/></p>



## Web scraping

NOAA tidak menyediakan API untuk mengambil data erupsi gempa bumi yang ada di seluruh dunia, sehingga kami harus melakukan web scraping secara manual, yaitu dengan mengambil tabel yang berada dalam source HTML website Volcano Event dari NOAA.

**Bahan-bahan yang digunakan untuk web scraping ini adalah:**

- [Google Chrome](https://www.google.com/intl/id_ALL/chrome/) / Browser Lainnya

- [Excel](https://docs.google.com/document/d/1baA9E5ciLhOmI-0TkWy9WpAOXH8sxLv4-at5e28FrbM/edit)

- [Zamzar-Free Online File Conversion](https://www.zamzar.com/)

**Tahap yang dilakukan adalah:**

-Membuka website Volcano Event dari NOAA, kemudian membuka [source page HTML](view-source:https://www.ngdc.noaa.gov/nndc/struts/results?ge_23=&le_23=&type_15=Like&query_15=&op_30=eq&v_30=&type_16=Like&query_16=&op_29=eq&v_29=&type_31=EXACT&query_31=None+Selected&le_17=&ge_18=&le_18=&ge_17=&op_20=eq&v_20=&ge_7=&le_7=&bt_24=&st_24=&ge_25=&le_25=&bt_26=&st_26=&ge_27=&le_27=&type_13=Like&query_13=&type_12=Exact&query_12=&type_11=Exact&query_11=&display_look=50&t=102557&s=50) dari website tersebut.

-Mencari tabel yang biasa dimulai dengan &lt;table&gt; dan diakhiri dengan &lt;/table&gt;, perlu dilihat juga dalam tabel tersebut terdapat 3 tabel, jadi harus dilihat terlebih dahulu dimana yang didalamnya terdapat tabel data erupsi.

-Setelah menemukan tabel tersebut kemudian ambil dari &lt;tabel&gt; sampai &lt;/tabel&gt;, setelah itu copy, kemudian buka tools untuk mengkonversi dari HTML ke CSV menggunakan Zamzar-Free Online File Conversion.

-Hasil CSV akan dikirimkan melalui email, setelah itu data.csv tersebut dirapikan kembali menggunakan excel, dikarenakan data yang ada masih berantakan dan memiliki parent table yang tidak sesuai.

-Data yang berformat [.csv](https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/VolcanoData.csv) tersebut telah siap untuk diolah.

## Pemodelan

Pemodelan dilakukan dengan cara merapikan data hasil dari web scraping dengan membuang data yang tidak diperlukan, serta mengisi data yang kosong sesuai dengan keperluan, kemudian merubah tipe data yang ada, seperti contohnya: date.

**Proses merapikan data utama:**

- Membuat semua data menjadi NA.

_na.strings=c(&quot;&quot;, &quot;NA&quot;)_

_MyData[MyData==&quot;&quot;] &lt;- NA_

 - Menghapus kolom data yang tidak diperlukan.

(Data tersisa: Year, Mo, Dy, Latitude, Longitude, Erup.VEI)

_MyData &lt;- subset(MyData, select=-c(Tsu,EQ,Addl.Vol.Info,Name,Location,Country,Elevation,Type,Erupt.Agent,Death.Num,Death.De,Injured.Num,Injured.De,Damage..Mill,Damage.De,Houses.Num,Houses.De,Photos))_

 - Menghapus semua data yang memiliki data NA, dikarenakan ada data erupsi yang tidak memiliki bulan dan hari, sehingga akan lebih baik kalau data tersebut dihapus.

_MyData&lt;-na.omit(MyData)_

 - Membuat type data Date dan menggabungkannnya dari data Year, Mo, Dy.

_MyData$Date &lt;- as.Date(with(MyData, paste(MyData$Year, MyData$Mo, MyData$Dy, sep=&quot;-&quot;), &quot;%Y-%m-%d&quot;))_

 - Menghapus data Year, Mo, Dy.

_MyData &lt;- subset(MyData, select=-c(Year,Mo,Dy))_

 - Merubah data date menjadi kolom pertama.

_MyData &lt;- MyData[c(4,1,2,3)]_


**Proses merapikan data Date dan Erup.VEI:**

- Mengambil data utama dan dibuat menjadi variabel baru.

_data &lt;- MyData_

- Menghapus latitude dan longitude.

_data &lt;- subset(data, select=-c(Latitude,Longitude))_

- Membuat semua data 0 yang ada di Erup.VEI menjadi NA.

_data$Erup.VEI[data$Erup.VEI==0] &lt;- NA_

- Merubah data Date menjadi ds dan  Erup.VEI menjadi y.

_ds &lt;-data$Date_

_y &lt;- log(data$Erup.VEI)_

- Membuat dataframe dari ds dan y.

_df &lt;- data.frame(ds,y)_

 *Notes:

-ds: berisi tanggal prediksi yang harus dibuat.

-y: berisi ramalan yang dibuat.

-df: dataframe.


**Prediksi Date dan Erup.VEI:**

 - Membuat prediksi Date selama 155 hari kedepan.

_m &lt;- prophet(df)_

_future &lt;- make\_future\_dataframe(m, periods = 155)_

  - Membuat prediksi Erup.VEI.

_forcast &lt;- predict(m,future)_


**Proses merapikan dan prediksi data Erup.VEI berdasarkan Latitude dan Longitude:**
 - Mengambil data utama dan dibuat menjadi variabel baru.

_veidata &lt;- MyData_

 - Menghilangkan kolom Date.

_veidata &lt;- subset(veidata, select=-c(Date))_

 - Membagi menjadi 2 data, yaitu data training sebesar 0.7 dan test sebesar 0.3.

_set.seed(3)_

_id&lt;-sample(2,nrow(veidata),prob = c(0.7,0.3),replace = TRUE)_

_vei\_train&lt;-veidata[id==1,]_

_vei\_test&lt;-veidata[id==2,]_

 - Memilih data yang akan dilatih dari data training dan menjadikan bentuk decision tree

_vei\_model&lt;-rpart(Erup.VEI~., data = vei\_train)_

_vei\_model$frame$yval&lt;-round(vei\_model$frame$yval)_

 - Prediksi dengan metode decision tree

_pred\_vei&lt;-predict(vei\_model,newdata = vei\_test, type = &quot;vector&quot;)_

_pred\_vei&lt;-round(pred\_vei)_

 - Memasukkan kembali latitude dan langitude ke dalam hasil prediksi Erup.VEI

_pred\_vei&lt;-as.data.frame(pred\_vei)_

_pred\_vei$Latitude&lt;-vei\_test$Latitude_

_pred\_vei$Longitude&lt;-vei\_test$Longitude_

 - Merubah posisi kolom pred\_vei menjadi kolom terakhir

_pred\_vei&lt;-pred\_vei[c(2,3,1)]_

 - Proses pembentukan decision tree untuk prediksi Erup.VEI

_pred\_model&lt;-rpart(pred\_vei~.,data = pred\_vei)_

_pred\_model$frame$yval&lt;-round(pred\_model$frame$yval)_
  
  
Setelah semua pemodelan ini selesai, maka tahap selanjutnya adalah memasukkannya ke dalam bentuk website, yaitu menggunakakan library shiny atau library shinyAce.


**Pengertian Prediksi dengan Prophet**

Prophet adalah prosedur untuk memprediksi data deret waktu berdasarkan model aditif untuk mencocokan tren non-linear dengan musiman tahunan, mingguan, dan harian, ditambah efek liburan. Prophet bekerja dengan maksimal dengan rangkaian waktu yang memiliki efek musiman yang kuat dan data historis dari beberapa musim. Prophet lumayan kokoh untuk mengatasi kehilangan data dan pergeseran dalam tren, dan biasanya menangani outlier dengan baik.

Prediksi menggunakan prophet berasal dari perusahaan Facebook.

Dengan menggunakan prophet ada beberapa keuntungan yang didapat, antara lain:

1. Prophet membuat lebih mudah untuk membuat perkiraan yang masuk akal dan akurat.

2. Perkiraan Prophet dapat disesuaikan dengan cara yang intuitif untuk orang yang kurang ahli.

Prosedur dari Prophet adalah model regresi tambahan (additive regression model) dengan empat komponen utama:

- Suatu kurva pertumbuhan linear atau logistic. Prophet secara otomatis mendeteksi perubahan tren dengan memilih titik-titik kunci dari data.

- Model komponen tren tahunan yang menggunakan deret Fourier.

- Komponen tren mingguan menggunakan variabel dummy.

- Daftar liburan penting yang disediakan untuk pengguna.



**Pengertian Prediksi dengan Decision Tree**

Decision tree adalah pohon di mana setiap node mewakili fitur (atribut), setiap tautan (branch) mewakili keputusan (rule) dan setiap daun mewakili hasil (categorical or continues value).

DecisionTree merupakan salah satu yang memanfaatkan prinsip regresi:

-Regresi linear atau linear regression (LR), dalam hal ini adalah multiple linear regression (MLR), karena itu beberapa sumber juga menyebut DT sebagai &quot;pohon regresi&quot; atau &quot;regression tree&quot;.

-Melibatkan banyak variabel, dalam hal ini independent variables (IV).

-Bertujuan untuk mengurutkan peran IV tersebut kepada dependent variable (DV).

-Memerlukan pemahaman teori yang cukup dari penggunanya untuk dapat menjawab masalah (research question) dan untuk memberikan argumentasi terhadap DecisionTree yang dihasilkan oleh piranti lunak (Stata, Statistica, Minitab, SPSS, SAS, atau dalam hal ini kita menggunakan R dengan R Studio).

**Aplikasi Shiny untuk Web**

Untuk memvisualisasi data dengan baik, aplikasi kami membutuhkan empat masukan table untuk menampilkan informasi. Keempat tabel tersebut adalah :

·         Long

·         Lat

·         Date

·         Eruption VEI(_Volcanic Explosivity Index)_

Informasi ditampilkan di kolom utama, terbagi dalam 7 tab yang terdiri atas :

- _Eruption VEI before Predict using Prophet_. Grafik ini menjelaskan tentang berapa banyak erupsi beserta nilai _Volcanic Explosivity Index_ dalam kurun waktu 2010 hingga tahun 2018.
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/ErupVEI%20before%20Predict%20using%20Prophet.jpg"/></p>

- _Eruption VEI after Predict using Prophet_. Grafik ini menjelaskan tentang prediksi berapa besar _Frequency_ pada tahun-tahun berikutnya.
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/ErupVEI%20after%20Predict%20using%20Prophet.jpg"/></p>

- _Eruption VEI Component Conclusion_.  Grafik ini merupakan penggabungan dan  menjelaskan tentang _Trend_ Tahunan dari _Volcanic Explosivity Index_.
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/ErupVEI%20Component%20Conclusion.jpg"/></p>

- _Erup VEI before Predict using DT_. Grafik ini menunjukkan bahwa titik plot dari latitude dan longitude berdasarkan nilai Erup.VEI yang ada sebelum dilakukan prediksi dan nilai dari Erup.VEI dibedakan menjadi beberapa warna yang berbeda sesuai dengan levelnya masing-masing.
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/ErupVEI%20before%20Predict%20using%20DT.jpg"/></p>

- _Erup VEI after Predict using DT_. Grafik ini merupakan pemodelan hasil dari prediksi Erup.VEI  yang dapat dilihat nilai dari Erup.VEI dibedakan menjadi beberapa warna dan titik plot dari latitude dan longitude dibagi berdasarkan nilai dari Erup.VEI yang ada.
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/ErupVEI%20after%20Predict%20using%20DT.jpg"/></p>

**Decision Tree Erup.VEI before Predict**
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/DT%20ErupVEI%20before%20Predict.jpg"/></p>

**Decision Tree Erup.VEI after Predict**
<p align="center"><img src="https://github.com/rickhenhermawan/Data_Science_Eruption_Prediction/blob/master/Images/DT%20ErupVEI%20after%20Predict.jpg"/></p>


## Saran Pengembangan

1. Tampilan Antarmuka yang lebih efektif dalam menampilkan data.
2. Menambahkan fitur untuk dapat mengubah jarak jangka waktu yang lebih lama dari tahun 2010 sehingga dapat lebih jelas terlihat garis regresi prediksinya.
3. Menambahkan prediksi untuk lokasi pasti terjadinya erupsi di masa mendatang.
4. Menggunakan prediksi untuk menambahkan data _Eruption Volcanic Explosivity_ yang belum tertera dalam National Centers for Environmental Information.

## Google Docs

<a href="https://docs.google.com/document/d/1baA9E5ciLhOmI-0TkWy9WpAOXH8sxLv4-at5e28FrbM/edit"><img src="https://www.orrasis.com/img/google/docs.png" width="100" height="100"/></a>

## Disklaim

Data yang berasal dari NOAA hanya digunakan untuk kepentingan akademis semata.

Aplikasi Shiny ini dibuat oleh:
- [Kevin Jonathan / 00000013436](https://github.com/KouKejo)
- [Leonardo Bunjamin / 00000014225](https://github.com/leobunjamin)
- [Rickhen Hermawan / 00000012311](https://github.com/rickhenhermawan/)

Bertujuan untuk memenuhi tugas mata kuliah Frontier Technology Jurusan Teknik Informatika Universitas Pelita Harapan semester akselerasi 2017/2018.

