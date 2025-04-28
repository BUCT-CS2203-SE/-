declare module '@agconnect/database-server' {
    export function initializeApp(config?: any): AppInstance;

    interface AppInstance {
        cloudDB(): CloudDBInstance;
    }

    interface CloudDBInstance {
        openZone(zoneName: string): CloudDBZone;
    }

    interface CloudDBZone {
        query(objectType: any): Query;
        queryBuilder(): QueryBuilder;
        count(query: Query): Promise<number>;
        executeQuery(query: Query): QuerySnapshot;
    }

    interface QueryBuilder {
        or(...queries: Query[]): QueryBuilder;
        build(): Query;
    }

    interface Query {
        equalTo(field: string, value: any): Query;
        contains(field: string, value: string): Query;
        limit(limit: number): Query;
        skip(offset: number): Query;
        orderBy(field: string, direction: 'asc' | 'desc'): Query;
    }

    interface QuerySnapshot {
        hasNext(): boolean;
        next(): any;
        release(): void;
    }
} 