/*
Cleaning data in SQL Queries
*/

SELECT *
FROM KhangPortfolioProject.dbo.NashvilleHousing

--Standardize Date Format (Chỉnh định dạng ngày)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM KhangPortfolioProject.dbo.NashvilleHousing

ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE KhangPortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data (Thêm địa chỉ bị trống)

SELECT *
FROM KhangPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM KhangPortfolioProject.dbo.NashvilleHousing  a
JOIN KhangPortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM KhangPortfolioProject.dbo.NashvilleHousing  a
JOIN KhangPortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--Breaking out Adress into Individual Columns (Address, City, State) (Tách thông tin địa chỉ)

SELECT PropertyAddress
FROM KhangPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

FROM KhangPortfolioProject.dbo.NashvilleHousing

ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE KhangPortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE KhangPortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM KhangPortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM KhangPortfolioProject.dbo.NashvilleHousing

--Easier way to break Address
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM KhangPortfolioProject.dbo.NashvilleHousing


ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE KhangPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE KhangPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE KhangPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field (Chuyển Y, N thành Yes, No)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM KhangPortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM KhangPortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END



--Remove Duplicates (Xoá hàng trùng lặp)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				  UniqueID
				  ) row_num

FROM KhangPortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




--Delete Unused Columns (Xoá cột không dùng đến)

SELECT *
FROM KhangPortfolioProject.dbo.NashvilleHousing

ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE KhangPortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate