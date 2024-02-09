SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [portefolioproject].[dbo].[NashvilleHousing]

  -- standardize date format
  select *
  from portefolioproject.dbo.NashvilleHousing

  select SaleDate, CONVERT(DATE,SaleDate)
  from portefolioproject.dbo.NashvilleHousing

  Alter table portefolioproject.dbo.NashvilleHousing
  alter column SaleDate DATE

  -- populate property address data

  select PropertyAddress
  from portefolioproject.dbo.NashvilleHousing
  --where PropertyAddress is null
  order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portefolioproject.dbo.NashvilleHousing a
join portefolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portefolioproject.dbo.NashvilleHousing a
join portefolioproject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Break the address into individual columns (adress, city, state)

select PropertyAddress
  from portefolioproject.dbo.NashvilleHousing
  --where PropertyAddress is null
 -- order by ParcelID

 select 
 SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as address
 , SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress)) as address
 from portefolioproject.dbo.NashvilleHousing

 Alter table NashvilleHousing
 add propertysplitaddress nvarchar(255); 

 update NashvilleHousing
 set PropertysplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) 
  
Alter table NashvilleHousing
 add propertysplitcity nvarchar(255); 

 update NashvilleHousing
 set Propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress)) 

 select OwnerAddress
  from portefolioproject.dbo.NashvilleHousing

  select
  parsename(replace(owneraddress, ',', '.'),3)
  ,parsename(replace(owneraddress, ',', '.'),2)
  ,parsename(replace(owneraddress, ',', '.'),1)
  from portefolioproject.dbo.NashvilleHousing

Alter table NashvilleHousing
 add ownersplitaddress nvarchar(255); 

 update NashvilleHousing
 set ownersplitAddress = parsename(replace(owneraddress, ',', '.'),3) 
  
Alter table NashvilleHousing
 add ownersplitcity nvarchar(255); 

 update NashvilleHousing
 set ownersplitcity = parsename(replace(owneraddress, ',', '.'),2)

 Alter table NashvilleHousing
 add ownersplitstate nvarchar(255); 

 update NashvilleHousing
 set ownersplitstate = parsename(replace(owneraddress, ',', '.'),1)

 select *
  from portefolioproject.dbo.NashvilleHousing

  -- change Y and N to yes and No in "sold as vacant" field

  select distinct(soldasvacant), count(Soldasvacant)
  from portefolioproject.dbo.NashvilleHousing
  group by SoldAsVacant
  order by 2

select Soldasvacant
 , case when SoldAsVacant ='Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end
  from portefolioproject.dbo.NashvilleHousing

  update NashvilleHousing
  set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end

 -- remove duplicates
with rownumcte as (
 select * ,
 row_number() over (
 partition by parcelid,
 propertyaddress,
 saleprice,
 saledate,
 legalreference
 order by 
 uniqueid
 ) row_num

 from portefolioproject.dbo.NashvilleHousing
 --order by parcelid
)
select *
from rownumcte
where row_num >1
order by PropertyAddress

-- delete unused columns

select *
from portefolioproject.dbo.NashvilleHousing

alter table portefolioproject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress