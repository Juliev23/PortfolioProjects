/****** Script for SelectTopNRows command from SSMS  ******/
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
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  ----------------------------------------------------------------------------------------------------------------
  --Cleaning Data in SQL Queries

  Select*
  FROM PortfolioProject.dbo.NashvilleHousing

 -----------------------------------------------------------------------------------------------------------------------
 
 --Standardize Date Format
  
  Select SaleDateConverted, CONVERT(Date, SaleDate)
  FROM PortfolioProject.dbo.NashvilleHousing

  Update NashvilleHousing
  SET SaleDate = CONVERT(Date,SaleDate)

  ALTER TABLE NashvilleHousing
  ADD SaleDateConverted Date;

  Update NashvilleHousing
  SET SaleDateConverted = CONVERT(Date,SaleDate)

  -----------------------------------------------------------------------------------------------------------

  --Populate Property Address Data

  Select PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing
  Where PropertyAddress is null

  Select *
  FROM PortfolioProject.dbo.NashvilleHousing
  --Where PropertyAddress is null
  Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing
  --Where PropertyAddress is null
  --Order by ParcelID

  -- Using a Substring and Character Index

  SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
  , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
  FROM PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
  
  ALTER TABLE NashvilleHousing
  ADD PropertySplitCity Nvarchar(255);
  
  Update NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

  Select *
  FROM PortfolioProject.dbo.NashvilleHousing

  Select OwnerAddress
  From PortfolioProject.dbo.NashvilleHousing 

  Select
  PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
  ,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
  ,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
   From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
  
  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity Nvarchar(255);
  
  Update NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState Nvarchar(255);
  
  Update NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

---------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), count (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Add a casse statement

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


----------------------------------------------------------------------------------------------------

--Remove Dupicates (best practice to create a temp table - not a good idea to delete data from the database- this is just an example of how to remove duplicates)

-- write a CTE and use windows functions [partition by] to find where there are duplicate values. Write query first, then put into a CTE. Using row number to identify rows. Pretend unique ID is not there and make each row unique with no duplicate data (e.g., ParcelID, SaleDate, PropertyAddress, SalePrice, LegalReference is same data)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) row_num

  FROM PortfolioProject.dbo.NashvilleHousing
  --order by ParcelID
  )
 SELECT *
  From RowNumCTE
  where row_num > 1
 Order by PropertyAddress


 ----------------------------------------------------------------------------------------------------------
 -- Delete Unused Columns
 -- Do not detele actual data off a database

  Select *
  FROM PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE PortfolioProject.dbo.NashvilleHousing
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

   ALTER TABLE PortfolioProject.dbo.NashvilleHousing
  DROP COLUMN SaleDate