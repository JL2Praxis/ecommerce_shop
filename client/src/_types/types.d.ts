export interface AdminType {
  firstName: string
  lastName: string
}

export interface ShopType {
  id: string
  name: string
  admins: AdminType[]
}

export interface CurrentUserType {
  id: string
  email: string
  firstName: string
  lastName: string
  role: {
    id: string
    name: string
    level: number
  }
  currentShop: {
    id: string
    name: string
  }
}

export type ButtonTypeType = 'normal' | 'accent' | 'warning' | 'success' | 'disabled'

export interface ButtonType {
  title: string
  type: ButtonTypeType
  icon?: string
  handler: () => any
}

export interface ProductType {
  id: string
  name: string
  slug: string
  status: ProductStatusType
  price: PriceType
  productType: ProductTypeType
  description: string
  categories: string[]
  image: string
  updatedAt: number
  createdAt: number
}

export type ProductStatusType = 'published' | 'unpublished' | 'archived' | 'unknown'
export type ProductTypeType = 'physical' | 'digital' | 'service' | 'advanced'

export interface CustomerType {
  id: string
  firstName: string
  lastName: string
  email: string
}

export type OrderStatusType = 'unfulfilled' | 'fulfilled' | 'refunded' | 'disputed'

export interface OrderType {
  id: string
  orderNumber: string
  customer: CustomerType
  total: string
  status: OrderStatusType
  updatedAt: number
  createdAt: number
}

export interface PriceType {
  amount: string
  currency: string
}

// Queries & Mutations

export interface QueryVariablesType {
  page: number
  perPage: number
}

export interface CreateShopVariablesType {
  shopName: string
  adminEmail: string
  adminFirstName: string
  adminLastName: string
}

export interface CreateProductVariablesType {
  name: string
  slug: string
  status: ProductStatusType | ''
  price: PriceType
  productType: ProductTypeType | ''
  categories: string[]
  description: string
}

export type UpdateProductVariablesType = CreateProductVariablesType & { id: string }
