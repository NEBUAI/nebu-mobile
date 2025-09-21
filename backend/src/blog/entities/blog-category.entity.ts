import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { BlogPost } from './blog-post.entity';

@Entity('blog_categories')
@Index(['slug'])
export class BlogCategory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;

  @Column({ unique: true, length: 100 })
  slug: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'timestamptz', nullable: true })
  color: string; // Hex color for UI

  @Column({ type: 'timestamptz', nullable: true })
  icon: string; // Icon name or URL

  @Column({ type: 'text', nullable: true })
  metaDescription: string;

  // Automation-specific fields
  @Column({ type: 'timestamptz', nullable: true })
  automationComplexity: string; // 'Basic', 'Intermediate', 'Advanced'

  @Column({ type: 'simple-array', nullable: true })
  relatedTools: string[]; // ['Zapier', 'Make', 'Power Automate']

  @Column({ type: 'simple-array', nullable: true })
  targetAudience: string[]; // ['Small Business', 'Freelancers', 'Enterprises']

  @OneToMany(() => BlogPost, (post) => post.category)
  posts: BlogPost[];

  @Column({ default: 0 })
  postCount: number;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Virtual field for URL
  get url(): string {
    return `/blog/category/${this.slug}`;
  }
}
