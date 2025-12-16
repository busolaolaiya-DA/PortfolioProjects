/*Cleaning data
*/

select * from PortfolioProjects..NashvilleHousing


--Standardize date format

select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProjects..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)



--Populate Property Address data

select PropertyAddress
from PortfolioProjects..NashvilleHousing
where PropertyAddress is null --to check if we have vacant addresses

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null -- now we do not have any null 



--Breaking out Address into individual columns(Address, city, state)

select PropertyAddress
From PortfolioProjects..NashvilleHousing

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City

From PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

Select * from PortfolioProjects..NashvilleHousing

Select OwnerAddress from PortfolioProjects..NashvilleHousing

--Using parsename instead of substrings to separate the address
--we replace the comma with periods since parsename works with period

Select 
Parsename(Replace(OwnerAddress,',', '.'), 3),
Parsename(Replace(OwnerAddress,',', '.'), 2),
Parsename(Replace(OwnerAddress, ',','.'), 1)
from PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress,',', '.'), 3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress,',', '.'), 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress,',', '.'), 1)

Select * from PortfolioProjects..NashvilleHousing


--Change Y and N to Yes and No to "sold as vacant" field

Select SoldAsVacant,
 CASE when SoldAsVacant = 'Y' Then 'Yes'
      when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
      END
from PortfolioProjects..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
      when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
      END



--Removing Duplicates
With RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID
			 ) row_num
from PortfolioProjects..NashvilleHousing
)
Select *
from RowNumCTE Where row_num > 1
Order by PropertyAddress /*we used delete to get rid of the duplicates 
and changed back to select to see if all duplicates were removed*/



--delete unused columns
select * from PortfolioProjects..NashvilleHousing
ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

