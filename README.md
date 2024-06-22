# ODA-project


## Project Description


  Development aid has been growing for the past decades, and more recently, China appears to be a big donator, alongside the countries from the Development Assistance Committee (DAC).  Our project is a comparison between the Official Development Assistance (ODA) flows of the Development Assistance Committee (DAC) and the ODA of China, with a focus on the sectors these two groups donate to.  Through this project we aim to look at the influence of GDP on the ODA flows that one sector receives.  Indeed, knowing that China has an alternative approach to development aid, *we ask ourselves what are the differences in sector allocation between DAC countries and China, and whether they respond similarly to economic changes* by using regression analysis.
  This project is based on the data retrieved from the OECD data bank and China's data is based on Version 3 of Aidata (2024), which previous studies such as Guillon et al. (2020) used, as China is not one of the DAC countries and of course its ODA isn't considered as ODA by these DAC countries. Because of the strict definition of ODA, previous studies either focus on DAC countries or emerging donors, such as China seperately. China has been known for challenging the way how DAC advocates and allocates ODA, and has been reshaping it with its characteristics (Bräutigam, 2011).  In this sense, this project attempts to converge and compare two approaches of ODA.  
  In short, this project analyze how donors allocate their ODA to different sectors, which is the most correlated with donors' GDP. 



## Getting Started

For this project, we use R studio with packages such as dyplr, ggplot2, openxlsx, stats.

###Data cleaning###

We have to first only keep the DAC countries ODA from the initatial dataset. 
Then, as China’dataset ranges from 2000 to 2020, We have to filter out DAC countries ODA that fall outside this time frame.  We also turn the values into numerics. 

Each dataset line provides crucial information: donor country, year, amount, and receiving sector. To prepare for regression analysis with GDP, we aggregate all sector observations by year. 

China's dataset includes additional columns "Description" and "Staff Comments", retained for later analysis.

In order to conduct our regression analysis, we have to make sure that there is no unknown value for the DAC countries dataset; in order to do so, we transform the dataframe into a wide format, and filtered out the missing data.  Finally we transform back to a long format. 


###Getting ready for the regression analysis###

We merge DAC ODA and China ODA dataframes together.  Now it’s time to make our baby dataframe grow by adding the **independent** and the **control variables**.  We aim at bringing our dataframe to maturity to prepare it for the regression! 

**Independent variable - GDP**
We get the information of China’s GDP from the World Bank dataset.  When it comes to DAC countries, we retrieve the GDP growth rates from OECD datasets.  For DAC countries’ variables, we always compute the average rate of DAC countries, they are considered in our analysis as a group.

With just the *independent variable* added to our merged dataframe, we obtain what we call **our baby blingbling**.

**Control Variables**

First we add the average employment rate of DAC countries, and the unemployment rate of China to our merged dataframe (the reason why we did not use the same control variable for both groups is due to limited availability for DAC countries´ unemployment rates and for China’s employement rates), now our baby dataframes is upgraded to **our toddler blingbling**. 

Then, we add Human Development Index (HDI), further upgrading our df to **our teen blingbling**, and public debt, bringing our dataframe to the the quasi-mature stage of **our young adult blingbling**.

Finally we add the average GDP growth rate of DAC countries to our dataframe, this step was quite challenging, but similarly to bringing a young adult to full maturity, it requires a lot of hardship so we FINALLY achieve the mature stage of **our grown-ass blingbling**. 

## File Structure

Attached to this project, you can find our R script and all the original datasets we used in the branch called _data sets_.
**Note: The aid data of China, named "China_Aids" is too big to be attached because of the upload limit, even though it has been compressed.
        Thus, this project appends the reference to the dataset here. The Chinese aid dataset was retrieved from Aidata, Version 3. (2024)
        Custer et al. (2023) have tracked Chinese finance and recorded it into a dataset for years, and this project takes advantage of the latest version.
## Analysis

1. First, we look for the top 5 sectors that receive the most allocations in order to see the donors priorities.

# ~~ **DAC COUNTRIES** ~~
For the DAC countries, we aggregate the values of the allocations by year and identify the five sectors that receive the most funding. The results are (1) Government and society, (2) Emergency response, (3) Education, (4) Population policies/programmes, and (5) Health. This demonstrates that DAC countries focus more on social sectors, as shown in Figure 1.

Figure 1: 
<img width="541" alt="Capture d’écran 2024-06-20 à 09 11 06" src="https://github.com/Skylhinn/ODA-project/assets/172566328/f5a6ac67-8f68-4aff-8d7c-b91c9c83fa6f">


# ~~ **CHINA** ~~

  **Visualisation of the top receiving sectors**

  For China, the top 5 sectors are (1)  other multisector, (2) transportation and storage, (3)energy, (4)industry, mining, construction, and (5) banking and financial services. Figure 2 shows that the line of other multisector skyrocketed from around 2015 to 2018, and this project took a closer look and found the reason why it is defined as a "multisector" because it encompasses many sectors at the same time, such as education and transportation, infrastructure projects, and even economics, production, and social sectors at the same time, etc. 

Figure 2:
  <img width="558" alt="Capture d’écran 2024-06-20 à 09 07 50" src="https://github.com/Skylhinn/ODA-project/assets/172566328/fac893a7-546b-4ef8-a656-f7631792b497">

  This is interesting considering China's largest donor sector is "Other multi-sector." Our dataset, which includes project descriptions and recipient information, shows that many ODA projects in this sector are directly or indirectly linked to mining, such as vocational schools or transport infrastructure. Most importantly, this project found that for instance, the majority of recipients under the other multisector are invited to the **Belt and Road Initiative**, except for Mauritius, Gaza, etc, or cross multiple nations. 




2. REGRESSION ANALYSIS 

The next step in our annalysis is running a regression to see which sectors are more affected by the donors country GDP with our 3 control variables: the average employment rate, the average human development index (HDI) and the average Debt/gdp ratio. 

# ~~ **DAC COUNTRIES** ~~

For DAC countries we chose the dates 2004-2019 because they have less data missing 
**Dependent variable**: Allocations by sector

**Independent variable**:
- Average Growth Rate of DAC countries

**Control variables**: 
- Average Employment Rate of DAC countries
- Average Human Development Index of DAC countries
- Average Debt/GDP ratio of DAC countries

The results of the regression show that for many sectors there is a negative coefficient for the growth rate, this implies that higher growth rates in donor countries are associated with lower ODA allocations to various sectors. Nevertheless the relationship in many cases is non-significant (Sectors with statistically significant results (p-value < 0.05))


Focusing on a sector with a strong statistical significance (significant at the 1% level (p < 0.01).) and a high coefficient, that suggests a reliable negative relationship, we conclude that for DAC countries, the sectors that are the most affected by GDP variations are **"Education"** and **Other social infrastructures and services**.

Coefficient and significance: 
<img width="470" alt="Capture d’écran 2024-06-04 à 11 11 47" src="https://github.com/Skylhinn/ODA-project/assets/172566328/9020998d-8957-4d8e-969d-d7c67390354f">

Regression Line: 
<img width="645" alt="Capture d’écran 2024-06-03 à 23 03 32" src="https://github.com/Skylhinn/ODA-project/assets/172566328/9a73c8b2-412e-4443-9a4e-ea14f1f23037">


Figure 3:
<img width="378" alt="Capture d’écran 2024-06-20 à 07 43 46" src="https://github.com/Skylhinn/ODA-project/assets/172566328/7f95094d-4327-4e9b-b5ed-df901ebfa6be">

The graph (Figure 3) comparing the trajectories of GDP growth (dotted line) and ODA allocations to Education (blue line) clearly illustrates an inverse relationship. We can see steady increase in funding for Education between 2000 and 2008. However, this upward trend was disrupted by the economic crisis of 2008, as evidenced by the decline in GDP growth. Since then, the growth in funding for the Education sector has not returned to its previous trajectory. This indicates that GDP variation significantly impacts ODA allocations, particularly in this sector.


# ~~ **CHINA** ~~

For China, we run the regression analysis to figure out which specific sector is the most influenced by China´s GDP, and it turned out to be the sector of **transportation and storage**. (p<0.001) This project further delves into the correlation coefficient relationship between the ODA in the sector and transportation and storage and GDP. Figure 6. depicts the significant correlation coefficient effect of the sector of transportation on China's GDP. (R=0.53**) Namely, the more amount on transportation and storage, the higher GDP China may accomplish. 

Figure 6
![Trans and GDP](https://github.com/Skylhinn/ODA-project/assets/172566692/1cb6da3d-6eba-47fd-8e64-67127b94103b)


  Generally, this project attempts to discover any predictors of China's ODA and runs the regression analysis with some indicators, such as GDP, Human Development Index, (HDI), and Debt. It turns out that HDI is also a significant variable to explain China's ODA, but the effect is very limited. (Figure 7.) With these three indicators, this project also found that there is a negative relationship between Debt and the percentage taking up the amount of China's GDP. It can be interpreted that China is less willing to donate compared to its GDP when it has a higher debt. (Figure 8.)

Figure 7.
![Rplot04](https://github.com/Skylhinn/ODA-project/assets/172566692/40b41b71-c1ae-4e1f-bea7-2b9be80a8be2)

Figure 8.
![Debt and Ratio](https://github.com/Skylhinn/ODA-project/assets/172566692/2ee89db2-e0e7-48fb-b229-5132d5296031)

Consistent with Guillion et al., (2020) this project found that China allocates its ODA to economic sectors. The ODA for the transportation and storage sector is positively correlated and affected by China's GDP. It suggests that the higher the amount of the ODA of transportation, the higher the GDP, and vice versa. Besides the transportation sector, another spike, in other multisector from around 2015 to 2018, allowed many recipients to achieve cross-sector tasks at the same time. By specifically filtering with other multisector during that time and eliminating BRI members (Nedopil,2023), this project finds most recipients under multisector are BRI members, excluding Gaza, Mauritius, and Sao Tome and Principe.  
  However, one-half of China's lending to developing countries is not recorded in the main international databases used by researchers and practitioners alike. (Horn et al., 2021) Moreover, there are some vague definitions of flow types in data, which were eliminated by this project. Hence, there might be more latent possibilities differentiating significance. Indeed, as Guillion et al. (2020) stated, China puts its policy consideration and national interest first place, but it is controversial but critical to bear in mind that these emerging donors, such as China may incur latent influences on developing countries through their definition of ODA and challenges to DAC. 
  
## Results

In summary, DAC countries and China prioritize different sectors in their aid allocations: DAC countries tend to focus on social sectors, while China emphasizes economic sectors.

However, regression analysis reveals that, regardless of these priorities, sector allocations —specifically "Education" and "Other social sectors" for DAC countries and "Transportation" for China — are primarily influenced by economic factors, particularly GDP variation. It is important to note, though, that many other sectors showed no significant relationship with GDP variation, indicating that GDP alone cannot fully explain ODA allocation patterns.

To further explore this subject, a more detailed analysis of individual donor countries and their specific recipient countries would be valuable. Examining these relationships on a country-by-country basis, rather than as a collective DAC bloc, could provide insights into the motivations and patterns of aid allocation. This approach would be particularly informative in understanding the impact of historical relationships between donor countries and their former colonies. Such an analysis could reveal additional factors beyond GDP variation that influence aid distribution, offering a more comprehensive view of international aid strategies and approaches.


## Contributors

This project has been conducted under the class Professor Pien Torrent *Big Data For Social Social Analysis* of NCCU. Our wonderful team is made of
安斐拉(112202180) aka Raphaela Nina Andersen, mainly worked on priority sectors and regression analysis for DAC countries,
范友誠(111461006) aka Roger, mainly worked on regression analysis for China and literature review,
蕭沛欣(112203152) aka Pauline, mainly worked on data cleaning, priority sectors of China and retrieved data for independent and dependent variables (nurturing our baby dataframe to the stage of grow ass blingbling).


## Acknowledgments

Thank you  Professor Pien Torrent for all the insides, ideas and encouragements that allowed us to bring this project to maturity despite all the challenges encountered, thank you also to our TAs Joanna and Maobin.

## References

Aid (ODA) by sector and donor [DAC5] (2024, Mar 27) OECD.  Retrieved from https://data-explorer.oecd.org/vis?fs[0]=Topic%2C1%7CDevelopment%23DEV%23%7COfficial%20Development%20Assistance%20%28ODA%29%23DEV_ODA%23&pg=0&bp=true&snb=11&vw=tb&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_DAC1%40DF_DAC5&df[ag]=OECD.DCD.FSD&df[vs]=1.0&pd=%2C&dq=ALLD.528....Q.&ly[rw]=SECTOR&ly[cl]=TIME_PERIOD&to[TIME_PERIOD]=false&lo=5&lom=LASTNPERIODS 
Aidata (2024) AidData's Global Chinese Development Finance Dataset (Version 3.0). Retrieved from https://www.aiddata.org/data/aiddatas-global-chinese-development-finance-dataset-version-3-0 
Bräutigam, D. (2011) Aid ‘with Chinese Characteristics’: Chinese Foreign Aid and Development Finance Meet The OECD-DAC Aid Regime. Journal of International Development. 23. pp.752–764 
Custer, S., Dreher, A., Elston, T.B., Escobar, B., Fedorochko, R., Fuchs, A., Ghose, S., Lin, J., Malik, A., Parks, B.C., Solomon, K., Strange, A., Tierney, M.J., Vlasto, L., Walsh, K., Wang, F., Zaleski, L., and Zhang, S. (2023) Tracking Chinese Development Finance: An Application of AidData’s TUFF 3.0 Methodology. Williamsburg, VA: AidData at William & Mary.
Dreher, A., Fuchs, A., Parks, B. C., Strange, A., & Tierney, M.J. 2022. Banking on Beijing: The Aims and Impacts of China’s Overseas Development Program. Cambridge, UK: Cambridge University Press.
Guillon, M., Mathonnat, J. (2020) What can we learn on Chinese aid allocation motivations from available data? A sectorial analysis of Chinese aid to African countries. China Economic Review. 60 (2020) 101265.
Horn, S., Reinhart, C., Trebesch, C. (2021) China's overseas lending. Journal of International Economics 133 (2021) 103539 https://doi.org/10.1016/j.jinteco.2021.103539
Nedopil, Christoph (2023): “Countries of the Belt and Road Initiative”; Shanghai, Green Finance & Development Center, FISF Fudan University, www.greenfdc.org
Wheat, M. (2017) Which Countries Provide and Receive the Most Foreign Aid? Wristband Resource. Retrieved from https://www.wristband.com/content/which-countries-provide-receive-most-foreign-aid

